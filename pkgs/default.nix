{ lib, pkgs }:
{
  kde-active-accent-decorations = pkgs.callPackage ./kde-active-accent-decorations { };
  kde-bismuth = pkgs.callPackage ./kde-bismuth { };
  kde-html-wallpaper = pkgs.callPackage ./kde-html-wallpaper.nix { };
  kde-onedark = pkgs.callPackage ./kde-onedark.nix { };
  kde-sticky-windows = pkgs.callPackage ./kde-sticky-windows.nix { };

  cad-blender = pkgs.callPackage ./cad-blender.nix { };
  cura = pkgs.callPackage ./cura.nix { };
  handheld-daemon = pkgs.callPackage ./handheld-daemon.nix { };
  minecraft-server-fabric_1_20_4 = pkgs.callPackage ./minecraft-server-fabric_1_20_4.nix { };
  nerdfont-hack-braille = pkgs.callPackage ./nerdfont-hack-braille.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme.nix { };
  steamgrid = pkgs.callPackage ./steamgrid { };
  two-finger-history-jump = pkgs.callPackage ./two-finger-history-jump.nix { };
  vencord-midnight-theme = pkgs.callPackage ./vencord-midnight-theme { };
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge.nix { };
}
