{ pkgs, ... }: {
  css-loader = pkgs.callPackage ./css-loader { };
  hhd-decky = pkgs.callPackage ./hhd-decky { };
  moondeck = pkgs.callPackage ./moondeck { };
}
