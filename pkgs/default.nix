{ pkgs, ... }:
rec {
  kde-active-accent-decorations = pkgs.callPackage ./kde-active-accent-decorations { };
  kde-html-wallpaper = pkgs.callPackage ./kde-html-wallpaper.nix { };
  kde-onedark = pkgs.callPackage ./kde-onedark.nix { };
  kde-panon = pkgs.callPackage ./kde-panon.nix { };

  leaf-theme-kde = pkgs.callPackage ./leaf-theme/kde.nix { };
  leaf-theme-vscode = pkgs.callPackage ./leaf-theme/vscode.nix { };

  vscode-highlight-regex = pkgs.callPackage ./vscode-highlight-regex.nix { };

  decky-moondeck = pkgs.callPackage ./decky/moondeck.nix { };

  adjustor = pkgs.callPackage ./adjustor.nix { };

  css-loader-desktop = pkgs.callPackage ./css-loader-desktop { };
  cura = pkgs.callPackage ./cura.nix { };
  minecraft-server-fabric_1_20_4 = pkgs.callPackage ./minecraft-server-fabric_1_20_4.nix { };
  openvpn3-indicator = pkgs.callPackage ./openvpn3-indicator { };
  plasma-drawer = pkgs.callPackage ./plasma-drawer.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme.nix { inherit plasmadeck; };
  vencord-midnight-theme = pkgs.callPackage ./vencord-midnight-theme { };
}
