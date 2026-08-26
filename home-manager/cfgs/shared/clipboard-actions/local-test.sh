#!/usr/bin/env bash
flake_path='.#nixosConfigurations.lynx.config.home-manager.users.faupi.services.clipboardActions'
export WOFI_CSS='home-manager/modules/clipboard-actions/wofi.css'

nix build "$flake_path.runtimeEnv" --no-link
nix build "$flake_path.jsonConfig"

nix shell \
  "$flake_path.runtimeEnv" \
  --command \
  wl-paste --type text --watch home-manager/modules/clipboard-actions/main.sh result
