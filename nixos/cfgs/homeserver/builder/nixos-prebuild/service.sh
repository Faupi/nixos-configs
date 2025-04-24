#!/bin/bash
set -euo pipefail

# TODO: Clone flake for lockfile updates
flake=github:faupi/nixos-configs

configs=$(nix eval $flake#nixosConfigurations --apply 'builtins.attrNames' --json | jq -r '.[]')

echo "[nixos-prebuild] Starting builds at $(date)"
for config in $configs; do
  echo "[nixos-prebuild] Building $config..."
  nix-fast-build \
    --flake $flake#nixosConfigurations.${config}.config.system.build.toplevel \
    --no-link \
    --no-nom \
    --retries 3 ||
    echo "[nixos-prebuild] ❌ Failed: $config"
done
echo "[nixos-prebuild] All builds finished at $(date)"
