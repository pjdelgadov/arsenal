#!/usr/bin/env bash
set -euo pipefail

URL="https://github.com/pjdelgadov/arsenal/archive/refs/heads/main.zip"
DEST="$PWD/arsenal"

if ! command -v curl >/dev/null 2>&1; then
    echo "[ERROR] curl is not installed."
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "[ERROR] unzip is not installed."
    exit 1
fi

if [[ -e "$DEST" ]]; then
    echo "[ERROR] Directory already exists: $DEST"
    echo "[*] Exiting without making changes."
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Downloading Arsenal..."
curl -fL --retry 3 -o "$TMP_DIR/arsenal.zip" "$URL"

echo "[*] Extracting..."
unzip -q "$TMP_DIR/arsenal.zip" -d "$TMP_DIR"

mv "$TMP_DIR/arsenal-main" "$DEST"

echo "[+] Arsenal successfully downloaded to:"
echo "    $DEST"
