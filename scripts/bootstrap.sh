#!/usr/bin/env bash
set -euo pipefail

# Garante que corre a partir da root do repo, mesmo se chamado noutro diretório
REPO_ROOT="${REPO_ROOT:-/workspaces/ApacheSpark-CD}"
cd "$REPO_ROOT"

KERNEL_NAME="${KERNEL_NAME:-apache-spark-cd}"
KERNEL_DISPLAY="${KERNEL_DISPLAY:-PySpark (image) - ApacheSpark-CD}"

# Se quiseres desligar o bootstrap (ex.: em CI), define BOOTSTRAP_DISABLE=1
BOOTSTRAP_DISABLE="${BOOTSTRAP_DISABLE:-0}"

log()  { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "$BOOTSTRAP_DISABLE" == "1" ]]; then
  log "[bootstrap] disabled via BOOTSTRAP_DISABLE=1"
  exit 0
fi

command -v python >/dev/null 2>&1 || die "[bootstrap] python não encontrado"
command -v java >/dev/null 2>&1 || warn "[bootstrap] java não encontrado (Spark vai precisar de Java)"

log "[bootstrap] Python: $(python --version 2>&1)"
if command -v java >/dev/null 2>&1; then
  log "[bootstrap] Java: $(java -version 2>&1 | head -n 1)"
fi

# ----------------------------
# Kernel (idempotente)
# ----------------------------
# Só instala kernel se:
#  - ipykernel existe
#  - e kernel ainda não existe
if python -c "import ipykernel" >/dev/null 2>&1; then
  if jupyter kernelspec list 2>/dev/null | awk '{print $1}' | grep -qx "$KERNEL_NAME"; then
    log "[bootstrap] Jupyter kernel '$KERNEL_NAME' já existe. A manter."
  else
    log "[bootstrap] A registar kernel '$KERNEL_NAME'..."
    python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY" >/dev/null
    log "[bootstrap] Kernel instalado."
  fi
else
  warn "[bootstrap] ipykernel não está instalado. A saltar registo de kernel."
fi

log "[bootstrap] OK ✅"
