{ pkgs, ... }: rec {
  carl = pkgs.callPackage ./carl { };
  eclipse-shade = pkgs.callPackage ./eclipse-shade { };
  materia = pkgs.callPackage ./materia { };
  mystical-blue-theme = pkgs.callPackage ./mystical-blue-theme { };
  onedark = pkgs.callPackage ./onedark { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme { inherit plasmadeck; };
}
