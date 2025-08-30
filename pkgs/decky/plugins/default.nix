{ pkgs, ... }: {
  css-loader = pkgs.callPackage ./css-loader { };
  hhd = pkgs.callPackage ./hhd { };
  moondeck = pkgs.callPackage ./moondeck { };
  playcount = pkgs.callPackage ./playcount { };
}
