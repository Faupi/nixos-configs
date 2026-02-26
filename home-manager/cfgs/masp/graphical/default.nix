{ config, pkgs, fop-utils, ... }@args:
{
  imports = [
    ./klipper.nix
  ];

  flake-configs = {
    vivaldi = {
      enable = true;
      setAsDefault = true;
    };
    vscodium = {
      enable = true;
      setAsDefault = true;
      folderHandling.enable = true;
    };
    teams = {
      enable = true;
      autoStart = {
        enable = true;
        minimized = false;
      };
      klipperActions.enable = false;
    };
    plasma = {
      flowmodoro.enable = true;
    };
  };

  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium
    postman
    azuredatastudio

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)

    (bottles.override { removeWarningPopup = true; })
    remmina
    kdePackages.kdenlive
  ];

  programs = {
    zen-browser = {
      enable = true;
      profiles.masp = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/masp.nix" args) // { isDefault = true; };
    };
  };
}
