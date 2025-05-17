nix flake update nixpkgs-bleeding
sudo nixos-rebuild switch --flake $(dirname "$0") --show-trace --verbose "$@"
