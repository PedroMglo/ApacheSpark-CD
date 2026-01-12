#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# Config (podes sobrescrever via env)
# ---------------------------
REPO="${REPO:-PedroMglo/ApacheSpark-CD}"
RELEASE_TAG="${RELEASE_TAG:-Spark-BD_V1}"
DATA_DIR="${DATA_DIR:-data}"
MARKER="${MARKER:-$DATA_DIR/.ready}"

# Se estiver a 1, falha caso gh não esteja autenticado (modo "estrito")
REQUIRE_GH_AUTH="${REQUIRE_GH_AUTH:-0}"

# Se estiver a 1, força download mesmo que exista marker
FORCE_DATA_DOWNLOAD="${FORCE_DATA_DOWNLOAD:-0}"

# ---------------------------
# Helpers
# ---------------------------
log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# "soft die": para não bloquear o devcontainer (sai com 0)
soft_fail() {
  warn "$*"
  exit 0
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || soft_fail "Comando obrigatório não encontrado: $1 (vou continuar sem descarregar dados)"
}

# Proteção simples contra zip-slip: recusa entradas com '..' ou paths absolutos
zip_is_safe() {
  local zip="$1"
  unzip -Z1 "$zip" | awk '
    /^\// { bad=1 }
    /\.\.\// { bad=1 }
    END { exit bad ? 1 : 0 }
  '
}

# ---------------------------
# Pré-checks
# ---------------------------
need_cmd gh
need_cmd unzip
need_cmd sed
need_cmd sort
need_cmd tail

mkdir -p "$DATA_DIR"

if [[ "$FORCE_DATA_DOWNLOAD" == "1" ]]; then
  rm -f "$MARKER"
fi

if [[ -f "$MARKER" ]]; then
  log "Dados já existem (marker encontrado em $MARKER). A saltar download."
  log "Instalado: $(cat "$MARKER" 2>/dev/null || true)"
  exit 0
fi

log "A descarregar datasets..."
log "Repo: $REPO"
log "Release tag: $RELEASE_TAG"
log "Data dir: $DATA_DIR"

# ---------------------------
# GitHub auth (não bloqueante por defeito)
# - tenta autenticar automaticamente se existir GH_TOKEN
# ---------------------------
if ! gh auth status -h github.com >/dev/null 2>&1; then
  if [[ -n "${GH_TOKEN:-}" ]]; then
    log "Token detetado (GH_TOKEN). A tentar autenticar o GitHub CLI..."
    TOKEN="${GH_TOKEN}"
    echo "${TOKEN}" | gh auth login --with-token >/dev/null 2>&1 || true
  fi
fi

if gh auth status -h github.com >/dev/null 2>&1; then
  log "GitHub auth: OK"
else
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Não estás autenticado no GitHub CLI. Corre: gh auth login (ou define GH_TOKEN)."
  fi
  warn "Não estás autenticado no GitHub CLI. Vou tentar na mesma (pode falhar se o repo/release for privado)."
fi

# ---------------------------
# Lista assets e escolhe o mais recente
# Aceita:
#   - data_YYYY-MM-DD.zip  (ordem lexicográfica funciona)
#   - data_vX.Y.Z.zip      (ordem semver)
# Se existirem ambos, dá prioridade ao de data (mais explícito).
# ---------------------------
log "A procurar assets na release '$RELEASE_TAG'..."

assets="$(
  gh release view "$RELEASE_TAG" \
    --repo "$REPO" \
    --json assets \
    --jq '.assets[].name' \
  2>/dev/null || true
)"

# Aqui está a principal diferença: em vez de die -> soft_fail (a não ser modo estrito)
if [[ -z "$assets" ]]; then
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Não consegui obter assets da release. Confirma REPO/RELEASE_TAG e permissões."
  fi
  soft_fail "Não consegui obter assets da release. Confirma REPO/RELEASE_TAG e permissões. (não vou bloquear o devcontainer)"
fi

latest_date="$(
  printf '%s\n' "$assets" \
    | sed -n 's/^\(data_[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\.zip\)$/\1/p' \
    | sort \
    | tail -n 1
)"

latest_semver="$(
  printf '%s\n' "$assets" \
    | sed -n 's/^\(data_v[0-9]\+\.[0-9]\+\.[0-9]\+\.zip\)$/\1/p' \
    | sort -V \
    | tail -n 1
)"

ASSET_NAME="${latest_date:-${latest_semver:-}}"

if [[ -z "${ASSET_NAME}" ]]; then
  warn "Nenhum asset com padrão esperado foi encontrado."
  log "Esperado: data_YYYY-MM-DD.zip ou data_vX.Y.Z.zip"
  log "Assets disponíveis:"
  printf '%s\n' "$assets"

  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    exit 1
  fi
  exit 0
fi

log "Asset escolhido: $ASSET_NAME"

# ---------------------------
# Download e unzip
# ---------------------------
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

log "A descarregar asset da release..."
if ! gh release download "$RELEASE_TAG" \
  --repo "$REPO" \
  --pattern "$ASSET_NAME" \
  --dir "$tmpdir" \
  >/dev/null 2>&1; then
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Falhou download via gh. Confirma permissões/token e a release."
  fi
  soft_fail "Falhou download via gh. Vou continuar sem bloquear o devcontainer."
fi

zip_path="$tmpdir/$ASSET_NAME"
if [[ ! -f "$zip_path" ]]; then
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Download falhou: não encontrei $zip_path"
  fi
  soft_fail "Download falhou: não encontrei $zip_path (vou continuar sem bloquear o devcontainer)"
fi

if ! zip_is_safe "$zip_path"; then
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "ZIP parece inseguro (paths absolutos ou '..'). A abortar unzip."
  fi
  soft_fail "ZIP parece inseguro (paths absolutos ou '..'). Não vou extrair. (não vou bloquear o devcontainer)"
fi

log "A extrair para '$DATA_DIR'..."
if ! unzip -o "$zip_path" -d "$DATA_DIR" >/dev/null 2>&1; then
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Falhou unzip do dataset."
  fi
  soft_fail "Falhou unzip do dataset. Vou continuar sem bloquear o devcontainer."
fi

# Marca como pronto (guarda o nome instalado)
echo "$ASSET_NAME" > "$MARKER"
log "Done. Installed: $ASSET_NAME"
