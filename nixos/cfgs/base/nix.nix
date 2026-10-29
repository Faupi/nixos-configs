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
      "https://cache.lantian.pub/lantian"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "jovian-nixos.cachix.org-1:mAWLjAxLNlfxAnozUjOqGj4AxQwCl7MXwOfu7msVlAo="

      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
    ];

    max-substitution-jobs = 128;
    fallback = true; # Fall back to local builds if a binary cache substituter cannot be reached.
  };

  # Auto GC and optimizations
  nix.optimise.automatic = true;
  nix.gc = mkDefaultRecursively {
    automatic = false;
    options = "--delete-older-than 14d";
    randomizedDelaySec = "10m"; # Delay so it doesn't block boot
  };
}
