#!/usr/bin/env bash
set -euo pipefail

cd "/srv/nixos-prebuild"

echo "Updating local flake"
git fetch --prune origin
git reset --hard origin/master

configs=$(nix eval .#nixosConfigurations --apply 'builtins.attrNames' --json | jq -r '.[]')
if [ -z "$configs" ]; then
  echo "No configurations found, skipping build" >&2
  exit 0
fi

echo "Starting builds at $(date)"
lastFail=0

for config in $configs; do
  echo "Building $config..."

  if nix-fast-build \
    --flake ".#nixosConfigurations.$config.config.system.build.toplevel" \
    --no-link \
    --no-nom \
    --retries 3 \
    --skip-cached \
    --option eval-cache false \
    --option keep-going true \
    2>&1 | sed -u "s/^/[$config] /"; then
    echo "Succeeded: $config"
  else
    buildStatus=$?
    echo "Failed: $config (exit code $buildStatus)"
    lastFail=$buildStatus
  fi
done

echo "Builds finished at $(date)"

exit "$lastFail"
