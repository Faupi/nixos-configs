{ pkgs, ... }: {
  css-loader = pkgs.callPackage ./css-loader.nix { };
  hhd-decky = pkgs.callPackage ./hhd-decky.nix { };
  moondeck = pkgs.callPackage ./moondeck.nix { };
}
