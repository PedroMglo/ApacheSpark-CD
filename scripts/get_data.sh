#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="data"
MARKER="$DATA_DIR/.ready"

ASSET_NAME="data.zip"
RELEASE_TAG="Spark-BD_V1"

mkdir -p "$DATA_DIR"

if [ -f "$MARKER" ]; then
  echo "Data already present."
  exit 0
fi

echo "Checking GitHub auth..."
gh auth status -h github.com >/dev/null

echo "Downloading release asset ($ASSET_NAME) from tag $RELEASE_TAG..."
tmpdir="$(mktemp -d)"
gh release download "$RELEASE_TAG" --pattern "$ASSET_NAME" --dir "$tmpdir"

echo "Unzipping into repo root..."
unzip -o "$tmpdir/$ASSET_NAME" -d .

touch "$MARKER"
echo "Done."