#!/usr/bin/env bash

set -euo pipefail

LOG_PREFIX="[nixos-prebuild]"

cd "/srv/nixos-prebuild"

echo "$LOG_PREFIX Updating local flake"
git fetch --prune origin
git reset --hard origin/master

configs=$(nix eval .#nixosConfigurations --apply 'builtins.attrNames' --json | jq -r '.[]')
if [ -z "$configs" ]; then
  echo "$LOG_PREFIX No configurations found, skipping build" >&2
  exit 0
fi

echo "$LOG_PREFIX Starting builds at $(date)"
lastFail=0
for config in $configs; do
  echo "$LOG_PREFIX Building $config..."
  nix-fast-build \
    --flake ".#nixosConfigurations.$config.config.system.build.toplevel" \
    --no-link \
    --no-nom \
    --retries 3 \
    --skip-cached \
    --option eval-cache false
  buildStatus=$?

  if [[ buildStatus -eq 0 ]]; then
    echo "$LOG_PREFIX ✅ Succeeded: $config"
  else
    echo "$LOG_PREFIX ❌ Failed: $config"
    lastFail=$buildStatus
  fi
done
echo "$LOG_PREFIX Builds finished at $(date)"

exit $lastFail
