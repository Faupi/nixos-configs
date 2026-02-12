{ pkgs, lib, ... }:
let
  inherit (pkgs) callPackage;
  inherit (lib) recurseIntoAttrs;
in
rec {
  decky = recurseIntoAttrs (callPackage ./decky { });
  kde = recurseIntoAttrs (callPackage ./kde { });
  vscode-extensions = pkgs.vscode-extensions // (recurseIntoAttrs (callPackage ./vscode-extensions { inherit fop-vscode-utils; }));

  leaf-theme-kde = callPackage ./leaf-theme/kde.nix { };
  leaf-theme-vscode = callPackage ./leaf-theme/vscode.nix { };

  fop-vscode-utils = callPackage ./vscode-extensions/fop-vscode-utils.nix { };

  css-loader-desktop = callPackage ./css-loader-desktop { };
  cura = callPackage ./cura.nix { };
  minecraft-server-fabric_1_20_4 = callPackage ./minecraft-server-fabric_1_20_4.nix { };
  nix-output-monitor-nerdfonts = callPackage ./nix-output-monitor-nerdfonts.nix { };
  openvpn3-indicator = callPackage ./openvpn3-indicator { };
  sddm-astronaut-faupi = callPackage ./sddm-astronaut-faupi.nix { };
  vencord-midnight-theme = callPackage ./vencord-midnight-theme { };
  vivaldi-custom-js = callPackage ./vivaldi-custom-js { };
  vscode-file-nesting-config = callPackage ./vscode-file-nesting-config { };
  vscodium-custom-css = callPackage ./vscodium-custom-css { };
  yet-another-monochrome-icon-set = callPackage ./yet-another-monochrome-icon-set { };
}
