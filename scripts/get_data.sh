#!/usr/bin/env bash
set -euo pipefail

# ---------------------------
# Config (podes sobrescrever via env)
# ---------------------------
REPO_ROOT="${REPO_ROOT:-/workspaces/ApacheSpark-CD}"
REPO="${REPO:-PedroMglo/ApacheSpark-CD}"
RELEASE_TAG="${RELEASE_TAG:-Spark-BD_V1}"

# data tem de ficar ao nível do root do repo
DATA_DIR="${DATA_DIR:-$REPO_ROOT/data}"
MARKER="${MARKER:-$DATA_DIR/.ready}"

REQUIRE_GH_AUTH="${REQUIRE_GH_AUTH}"
FORCE_DATA_DOWNLOAD="${FORCE_DATA_DOWNLOAD}"

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Não bloquear o devcontainer por defeito
soft_fail() { warn "$*"; exit 0; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || soft_fail "Comando obrigatório não encontrado: $1"
}

cd "$REPO_ROOT"
need_cmd gh
need_cmd python
need_cmd sed
need_cmd sort
need_cmd tail
need_cmd head

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
# ---------------------------
if gh auth status -h github.com >/dev/null 2>&1; then
  log "GitHub auth: OK"
else
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Não estás autenticado no GitHub CLI. Corre: gh auth login"
  fi
  warn "Não estás autenticado no GitHub CLI. Vou tentar na mesma (pode falhar se o repo/release for privado)."
fi

# ---------------------------
# Lista assets e escolhe o mais recente
# ---------------------------
log "A procurar assets na release '$RELEASE_TAG'..."

assets="$(
  gh release view "$RELEASE_TAG" \
    --repo "$REPO" \
    --json assets \
    --jq '.assets[].name' \
  2>/dev/null || true
)"

[[ -n "$assets" ]] || {
  if [[ "$REQUIRE_GH_AUTH" == "1" ]]; then
    die "Não consegui obter assets da release. Confirma REPO/RELEASE_TAG e permissões."
  fi
  soft_fail "Não consegui obter assets da release. Confirma REPO/RELEASE_TAG e permissões."
}

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
  exit 0
fi

log "Asset escolhido: $ASSET_NAME"

# ---------------------------
# Download
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
  # fallback: qualquer zip que tenha vindo
  zip_path="$(ls -1 "$tmpdir"/*.zip 2>/dev/null | head -n 1 || true)"
fi

[[ -f "${zip_path:-}" ]] || soft_fail "Download falhou: não encontrei o zip em $tmpdir"

# ---------------------------
# Extração robusta: extrai TUDO o que estiver dentro de qualquer pasta 'data/'
# e copia para $DATA_DIR removendo prefixos (evita data/data e evita wrapper dirs)
# ---------------------------
log "A extrair conteúdos de '.../data/*' do zip para $DATA_DIR ..."

export ZIP_PATH="$zip_path"
export DATA_DIR="$DATA_DIR"

python - <<'PY'
import os, zipfile
from pathlib import Path, PurePosixPath

zip_path = os.environ["ZIP_PATH"]
data_dir = Path(os.environ["DATA_DIR"])
data_dir.mkdir(parents=True, exist_ok=True)

def safe_join(base: Path, rel: PurePosixPath) -> Path:
    # evita zip-slip
    target = (base / Path(*rel.parts)).resolve()
    if not str(target).startswith(str(base.resolve())):
        raise ValueError(f"Unsafe path (zip-slip): {rel}")
    return target

count = 0
with zipfile.ZipFile(zip_path) as z:
    names = [n for n in z.namelist() if n and not n.endswith("/")]
    # pega entradas que contenham um segmento 'data'
    for n in names:
        p = PurePosixPath(n)
        parts = p.parts
        if "data" not in parts:
            continue
        i = parts.index("data")
        rel = PurePosixPath(*parts[i+1:])
        if len(rel.parts) == 0:
            continue  # era a pasta data, sem ficheiro
        target = safe_join(data_dir, rel)
        target.parent.mkdir(parents=True, exist_ok=True)
        with z.open(n) as src, open(target, "wb") as dst:
            dst.write(src.read())
        count += 1

print(f"[get_data] extracted_files={count}")
if count == 0:
    print("[get_data] WARN: não encontrei ficheiros dentro de nenhuma pasta 'data/' no zip.")
PY

# Só cria marker se houver ficheiros em DATA_DIR
file_count="$(find "$DATA_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')"
log "Ficheiros em $DATA_DIR: $file_count"

if [[ "$file_count" -eq 0 ]]; then
  warn "A pasta data continua vazia. Não vou criar marker."
  exit 0
fi

echo "$ASSET_NAME" > "$MARKER"
log "Done. Installed: $ASSET_NAME"
