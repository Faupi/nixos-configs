#!/usr/bin/env bash

pkgName=$1
opts=$2
shift 2
nix build --impure --builders "" --substituters "https://cache.nixos.org" --expr "(builtins.getFlake (toString $(dirname "$0")/.)).outputs.legacyPackages.x86_64-linux.$pkgName.override {${opts%;};}" "$@"
