#!/usr/bin/env bash
set -euo pipefail

REPO="oioioioi3/ApacheSpark-CD"   # <-- muda se necessário
RELEASE_TAG="Spark-BD_V1"         # a tua tag / release
DATA_DIR="data"
MARKER="$DATA_DIR/.ready"

mkdir -p "$DATA_DIR"

echo "Checking GitHub auth..."
gh auth status -h github.com >/dev/null

echo "Finding latest versioned data asset in release $RELEASE_TAG..."

assets="$(
  gh release view "$RELEASE_TAG" --repo "$REPO" --json assets --jq '.assets[].name'
)"

# 1) Preferir data_YYYY-MM-DD.zip
latest_date="$(
  printf '%s\n' "$assets" \
    | sed -n 's/^\(data_[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\.zip\)$/\1/p' \
    | sort \
    | tail -n 1
)"

# 2) Fallback: data_vX.Y.Z.zip (ordenar por versão)
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

# Se já tivermos exatamente esta versão, não faz nada
if [ -f "$MARKER" ] && grep -qx "$ASSET_NAME" "$MARKER"; then
  echo "Data already present ($ASSET_NAME)."
  exit 0
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

# Guardar qual foi a versão instalada
echo "$ASSET_NAME" > "$MARKER"

echo "Done. Installed: $ASSET_NAME"
