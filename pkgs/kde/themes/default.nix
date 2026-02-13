{ pkgs, ... }: rec {
  carl = pkgs.callPackage ./carl { };
  mystical-blue-theme = pkgs.callPackage ./mystical-blue-theme { };
  onedark = pkgs.callPackage ./onedark { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme { inherit plasmadeck; };
  eclipse-shade = pkgs.callPackage ./eclipse-shade { };
}
