{ pkgs, ... }:
{
  kde-active-accent-decorations = pkgs.callPackage ./kde-active-accent-decorations { };
  kde-html-wallpaper = pkgs.callPackage ./kde-html-wallpaper.nix { };
  kde-onedark = pkgs.callPackage ./kde-onedark.nix { };
  kde-panon = pkgs.callPackage ./kde-panon.nix { };

  leaf-theme = {
    kde = pkgs.callPackage ./leaf-theme/kde.nix { };
    vscode = pkgs.callPackage ./leaf-theme/vscode.nix { };
  };

  vscode-highlight-regex = pkgs.callPackage ./vscode-highlight-regex.nix { };

  adjustor = pkgs.callPackage ./adjustor.nix { };

  alvr = pkgs.callPackage ./alvr { };
  cura = pkgs.callPackage ./cura.nix { };
  minecraft-server-fabric_1_20_4 = pkgs.callPackage ./minecraft-server-fabric_1_20_4.nix { };
  nerdfont-hack-braille = pkgs.callPackage ./nerdfont-hack-braille.nix { };
  plasma-drawer = pkgs.callPackage ./plasma-drawer.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme.nix { };
  steamgrid = pkgs.callPackage ./steamgrid { };
  vencord-midnight-theme = pkgs.callPackage ./vencord-midnight-theme { };
}
