#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/pjdelgadov/arsenal.git"
DEST="$PWD/arsenal"

if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] Git is not installed."
    exit 1
fi

if [[ -e "$DEST" ]]; then
    echo "[ERROR] Directory already exists: $DEST"
    echo "[*] Exiting without making changes."
    exit 1
fi

echo "[*] Downloading Arsenal..."
git clone --depth 1 "$REPO" "$DEST"

echo "[+] Arsenal successfully downloaded to:"
echo "    $DEST"