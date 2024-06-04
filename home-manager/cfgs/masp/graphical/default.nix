{ config, pkgs, lib, ... }:
with lib;
{
  home.packages = with pkgs; [
    (config.lib.nixgl.wrapPackage krita)
    (config.lib.nixgl.wrapPackage moonlight-qt)
    haruna # Video player

    (config.lib.nixgl.wrapPackage epiphany)
    chromium
    postman

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)
  ];

  programs = {
    firefox.profiles.masp.isDefault = true;
  };
}
