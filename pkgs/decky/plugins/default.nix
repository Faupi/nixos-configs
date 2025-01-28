{ pkgs, ... }: {
  hhd-decky = pkgs.callPackage ./hhd-decky.nix { };
  moondeck = pkgs.callPackage ./moondeck.nix { };
}
