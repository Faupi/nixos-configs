{ config, pkgs, lib, ... }:
with lib;
{
  home.packages = with pkgs; [
    (config.lib.nixgl.wrapPackage krita)
    (config.lib.nixgl.wrapPackage epiphany)
    (config.lib.nixgl.wrapPackage moonlight-qt)
    localsend
    haruna # Video player
    postman
  ];

  programs = {
    firefox.profiles.masp.isDefault = true;
  };
}
