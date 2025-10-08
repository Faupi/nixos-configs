{ pkgs, ... }: {
  carl = pkgs.callPackage ./carl { };
  mystical-blue-theme = pkgs.callPackage ./mystical-blue-theme { };
  onedark = pkgs.callPackage ./onedark { };
}
