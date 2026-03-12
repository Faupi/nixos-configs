#!/usr/bin/env bash
set -euo pipefail

for f in "$@"; do
  [[ -L "$f" ]] || continue
  target="$(readlink -f -- "$f")"
  tmp="$(mktemp --tmpdir "$(basename "$f").XXXXXX")"
  cp -a -- "$target" "$tmp"
  chmod u+w "$tmp"
  mv -f -- "$tmp" "$f"
done
