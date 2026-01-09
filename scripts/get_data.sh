#!/usr/bin/env bash
set -euo pipefail

REPO="PedroMglo/ApacheSpark-CD"
RELEASE_TAG="Spark-BD_V1"
DATA_DIR="data"
MARKER="$DATA_DIR/.ready"

# Garante que a pasta existe (mesmo que já tenha sido criada pelo Docker)
mkdir -p "$DATA_DIR"

# Se já tivermos o marcador com o nome do asset instalado, não faz nada
if [ -f "$MARKER" ]; then
  echo "Dados já existem (marker encontrado em $MARKER), a saltar download."
  exit 0
fi

echo "A descarregar datasets..."
echo "Checking GitHub auth..."
gh auth status -h github.com >/dev/null

echo "Finding latest versioned data asset in release $RELEASE_TAG..."
assets="$(
  gh release view "$RELEASE_TAG" \
    --repo "$REPO" \
    --json assets \
    --jq '.assets[].name'
)"

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

if [ -z "${ASSET_NAME:-}" ]; then
  echo "ERROR: No versioned asset found. Expected data_YYYY-MM-DD.zip or data_vX.Y.Z.zip"
  echo "Assets available:"
  printf '%s\n' "$assets"
  exit 1
fi

echo "Downloading release asset ($ASSET_NAME) from tag $RELEASE_TAG..."
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

gh release download "$RELEASE_TAG" \
  --repo "$REPO" \
  --pattern "$ASSET_NAME" \
  --dir "$tmpdir"

echo "Unzipping into repo root..."
unzip -o "$tmpdir/$ASSET_NAME" -d .

echo "$ASSET_NAME" > "$MARKER"
echo "Done. Installed: $ASSET_NAME"