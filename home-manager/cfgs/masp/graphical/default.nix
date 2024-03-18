{ config, pkgs, lib, homeSharedConfigs, ... }:
with lib;
{
  imports = [
    homeSharedConfigs.syncDesktopItems
    homeSharedConfigs.kde-plasma
    homeSharedConfigs.kde-klipper
    homeSharedConfigs.kde-konsole
    (homeSharedConfigs.kde-bismuth {
      useNixBismuth = false; # TODO: Needs to be built against Ubuntu's packages
    })
    homeSharedConfigs.kde-kwin-rules
    homeSharedConfigs.vscodium
    homeSharedConfigs.easyeffects
    homeSharedConfigs.firefox
    homeSharedConfigs.spicetify
    homeSharedConfigs.teams
  ];

  home.packages = with pkgs; [
    (config.lib.nixgl.wrapPackage krita)
    (config.lib.nixgl.wrapPackage epiphany)
    (config.lib.nixgl.wrapPackage moonlight-qt)
  ];

  programs = {
    # 1Password is taken from system package manager

    firefox.profiles.masp.isDefault = true;
  };
}
