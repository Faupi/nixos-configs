sudo nix flake update nixpkgs-bleeding
sudo nixos-rebuild switch --flake $(dirname "$0") --refresh --show-trace --verbose "$@"
