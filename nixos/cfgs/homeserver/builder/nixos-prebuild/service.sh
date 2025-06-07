#!/bin/bash

# TODO: Clone flake for lockfile updates
flake=github:faupi/nixos-configs

configs=$(nix eval $flake#nixosConfigurations --apply 'builtins.attrNames' --json | jq -r '.[]')

echo "[nixos-prebuild] Starting builds at $(date)"

lastFail=0
for config in $configs; do
  echo "[nixos-prebuild] Building $config..."
  nix-fast-build \
    --flake $flake#nixosConfigurations.${config}.config.system.build.toplevel \
    --no-link \
    --no-nom \
    --retries 3 \
    --skip-cached \
    --show-trace
  buildStatus=$?

  if [[ buildStatus -eq 0 ]]; then
    echo "[nixos-prebuild] ✅ Succeeded: $config"
  else
    echo "[nixos-prebuild] ❌ Failed: $config"
    lastFail=$buildStatus
  fi
done
echo "[nixos-prebuild] Builds finished at $(date)"

exit $lastFail
