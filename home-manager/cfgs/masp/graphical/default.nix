{ config, pkgs, lib, ... }:
with lib;
{
  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium
    postman

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)

    bottles
    remmina
  ];

  programs = {
    firefox.profiles.masp.isDefault = true;
  };
}
