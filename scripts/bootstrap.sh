#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/ApacheSpark-CD

KERNEL_NAME="apache-spark-cd"
KERNEL_DISPLAY="PySpark (image) - ApacheSpark-CD"

echo "[bootstrap] Python: $(python --version)"
echo "[bootstrap] Java: $(java -version 2>&1 | head -n 1)"

# Garante kernel Jupyter (leve e útil)
python -m pip install --no-cache-dir -U ipykernel
python -m ipykernel install --user --name "$KERNEL_NAME" --display-name "$KERNEL_DISPLAY"

echo "[bootstrap] OK ✅"
