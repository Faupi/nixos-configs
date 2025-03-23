{ pkgs, ... }: {
  css-loader = pkgs.callPackage ./css-loader { };
  hhd-decky = pkgs.callPackage ./hhd-decky.nix { };
  moondeck = pkgs.callPackage ./moondeck { };
}
