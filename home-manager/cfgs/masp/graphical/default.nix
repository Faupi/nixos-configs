{ config, pkgs, lib, ... }:
with lib;
{
  home.packages = with pkgs; [
    (config.lib.nixgl.wrapPackage krita)
    (config.lib.nixgl.wrapPackage epiphany)
    (config.lib.nixgl.wrapPackage moonlight-qt)
  ];

  programs = {
    _1password = {
      enable = true;
      package = pkgs._1password-gui;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    firefox.profiles.masp.isDefault = true;
  };
}
