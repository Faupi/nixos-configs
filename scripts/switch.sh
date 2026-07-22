#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash jq
#shellcheck shell=bash

flake=$(nix flake metadata --json . | jq -r .url)

sudo true
nix flake update nixpkgs-bleeding
sudo nixos-rebuild switch --flake "$flake" --refresh --show-trace --verbose "$@" --log-format internal-json |& nom --json
