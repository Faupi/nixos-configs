{ config, pkgs, ... }:
{
  imports = [
    ./clipboard-actions.nix
  ];

  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)

    (bottles.override { removeWarningPopup = true; })
    remmina
    kdePackages.kdenlive
  ];
}
