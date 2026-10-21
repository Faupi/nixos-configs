#!/usr/bin/env nix-shell
#!nix-shell -i bash -p sops
#shellcheck shell=bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$FLAKE_ROOT"

export SOPS_AGE_KEY_CMD='op read "op://Personal/sops admin_faupi/keys.txt"'

find . -type f \( \
  -name 'secrets.yaml' -o \
  -name 'secrets.json' -o \
  -name 'secrets.ini' \
  \) -print0 |
  while IFS= read -r -d '' file; do
    echo "Updating: $file"
    sops updatekeys --yes "$file"
  done

echo "Finished updating SOPS files"
