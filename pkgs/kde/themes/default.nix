{ pkgs, ... }: {
  carl = pkgs.callPackage ./carl { };
  onedark = pkgs.callPackage ./onedark { };
}
