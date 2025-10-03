{ pkgs, ... }:
rec {
  decky = pkgs.recurseIntoAttrs (pkgs.callPackage ./decky { });
  kde = pkgs.recurseIntoAttrs (pkgs.callPackage ./kde { });
  vscode-extensions = pkgs.vscode-extensions // (pkgs.recurseIntoAttrs (pkgs.callPackage ./vscode-extensions { inherit fop-vscode-utils; }));

  leaf-theme-kde = pkgs.callPackage ./leaf-theme/kde.nix { };
  leaf-theme-vscode = pkgs.callPackage ./leaf-theme/vscode.nix { };

  fop-vscode-utils = pkgs.callPackage ./vscode-extensions/fop-vscode-utils.nix { };

  css-loader-desktop = pkgs.callPackage ./css-loader-desktop { };
  cura = pkgs.callPackage ./cura.nix { };
  minecraft-server-fabric_1_20_4 = pkgs.callPackage ./minecraft-server-fabric_1_20_4.nix { };
  nix-output-monitor-nerdfonts = pkgs.callPackage ./nix-output-monitor-nerdfonts.nix { };
  openvpn3-indicator = pkgs.callPackage ./openvpn3-indicator { };
  plasma-drawer = pkgs.callPackage ./plasma-drawer.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck { };
  plasmadeck-vapor-theme = pkgs.callPackage ./plasmadeck-vapor-theme.nix { inherit plasmadeck; };
  vencord-midnight-theme = pkgs.callPackage ./vencord-midnight-theme { };
  vscode-file-nesting-config = pkgs.callPackage ./vscode-file-nesting-config { };
  vscodium-custom-css = pkgs.callPackage ./vscodium-custom-css { };
}
