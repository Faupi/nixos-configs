nix build --impure --builders "" --substituters "https://cache.nixos.org" --expr "(builtins.getFlake (toString $(dirname "$0")/.)).outputs.legacyPackages.x86_64-linux.$1.override {${2%;};}"
