#!/usr/bin/env bash

pkgName=$1
overrideOpts=$2
shift 2

flake="(builtins.getFlake (toString $(dirname "$0")/.))"
pkgRef="$flake.outputs.legacyPackages.x86_64-linux.$pkgName"
override="override (old: {${overrideOpts%;};})"
overrideAttrs="overrideAttrs (old: {version = \"temp-$(date '+%Y%m%d%H%M%S')\"; __intentionallyOverridingVersion = true;})"
nix build --impure --builders "" --substituters "https://cache.nixos.org" \
  --expr "($pkgRef.$override).$overrideAttrs" \
  "$@"
