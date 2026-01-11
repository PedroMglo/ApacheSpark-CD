#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/ApacheSpark-CD

KERNEL_NAME="apache-spark-cd"
KERNEL_DISPLAY="PySpark (image) - ApacheSpark-CD"

echo "[bootstrap] Python: $(python --version)"
echo "[bootstrap] Java: $(java -version 2>&1 | head -n 1)"

# Regista kernel (idempotente)
python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY"

echo "[bootstrap] OK ✅"
