{ config, pkgs, fop-utils, ... }@args:
{
  imports = [
    ./klipper.nix
  ];

  flake-configs.teams = {
    enable = true;
    autoStart = {
      enable = true;
      minimized = false;
    };
    klipperActions.enable = false;
  };

  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium
    postman
    azuredatastudio

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)

    bottles
    remmina
  ];

  programs = {
    zen-browser = {
      enable = true;
      profiles.masp = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/masp.nix" args) // { isDefault = true; };
    };
  };
}
