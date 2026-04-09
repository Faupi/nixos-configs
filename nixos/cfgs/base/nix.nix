{ pkgs, fop-utils, ... }:
let
  inherit (fop-utils) mkDefaultRecursively;
in
{
  nix.package = pkgs.lix;

  # Package policies + cache
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];

    substituters = [
      "https://nix-community.cachix.org"
      "https://jovian-nixos.cachix.org"

      # nix-cachyos-kernel
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io" # fallback
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="

      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

    max-substitution-jobs = 128;
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = mkDefaultRecursively {
    automatic = false;
    options = "--delete-older-than 14d";
    randomizedDelaySec = "10m"; # Delay so it doesn't block boot
  };
}
