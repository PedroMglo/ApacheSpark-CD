#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/ApacheSpark-CD

VENV_PATH="/workspaces/ApacheSpark-CD/.venv"
REQ_PATH="/workspaces/ApacheSpark-CD/.devcontainer/requirements.txt"
KERNEL_NAME="apache-spark-cd"
KERNEL_DISPLAY="PySpark (.venv) - ApacheSpark-CD"

echo "[bootstrap] Python: $(python3 --version)"
echo "[bootstrap] Workspace: $(pwd)"

# 1) Criar venv se não existir
if [ ! -d "$VENV_PATH" ]; then
  echo "[bootstrap] Criar venv em $VENV_PATH"
  python3 -m venv "$VENV_PATH"
else
  echo "[bootstrap] venv já existe: $VENV_PATH"
fi

# 2) Atualizar pip e instalar deps
echo "[bootstrap] Upgrade pip/setuptools/wheel"
"$VENV_PATH/bin/python" -m pip install --upgrade pip setuptools wheel

if [ -f "$REQ_PATH" ]; then
  echo "[bootstrap] Instalar requirements: $REQ_PATH"
  "$VENV_PATH/bin/pip" install --no-cache-dir -r "$REQ_PATH"
else
  echo "[bootstrap][WARN] requirements.txt não encontrado em $REQ_PATH"
fi

# 3) Garantir kernel Jupyter (importante para notebooks)
echo "[bootstrap] Garantir ipykernel e registar kernel"
"$VENV_PATH/bin/pip" install --no-cache-dir ipykernel
"$VENV_PATH/bin/python" -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY"

echo "[bootstrap] OK ✅"
echo "[bootstrap] Interpreter: $VENV_PATH/bin/python"
