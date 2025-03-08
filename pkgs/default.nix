{ pkgs, ... }:
rec {
  decky = pkgs.callPackage ./decky { };
  vscode-extensions = pkgs.vscode-extensions // (pkgs.callPackage ./vscode-extensions { inherit fop-vscode-utils; });

  # TODO: Move under ./kde
  kde-active-accent-decorations = pkgs.callPackage ./kde-active-accent-decorations { };
  kde-html-wallpaper = pkgs.callPackage ./kde-html-wallpaper.nix { };
  kde-onedark = pkgs.callPackage ./kde-onedark.nix { };
  kde-panon = pkgs.callPackage ./kde-panon.nix { };

  leaf-theme-kde = pkgs.callPackage ./leaf-theme/kde.nix { };
  leaf-theme-vscode = pkgs.callPackage ./leaf-theme/vscode.nix { };

  fop-vscode-utils = pkgs.callPackage ./vscode-extensions/fop-vscode-utils.nix { };

  css-loader-desktop = pkgs.callPackage ./css-loader-desktop { };
  cura = pkgs.callPackage ./cura.nix { };
  minecraft-server-fabric_1_20_4 = pkgs.callPackage ./minecraft-server-fabric_1_20_4.nix { };
  openvpn3-indicator = pkgs.callPackage ./openvpn3-indicator { };
  plasma-drawer = pkgs.callPackage ./plasma-drawer.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme.nix { inherit plasmadeck; };
  vencord-midnight-theme = pkgs.callPackage ./vencord-midnight-theme { };
}
