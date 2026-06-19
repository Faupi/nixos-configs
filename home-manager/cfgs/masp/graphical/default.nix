{ config, pkgs, fop-utils, ... }@args:
{
  imports = [
    ./klipper.nix
  ];

  flake-configs = {
    plasma = {
      enable = true;
      reloadOnActivation = true;
      theme.enable = true;
      flowmodoro.enable = true;
    };
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

    dolphin.enable = true;
  };

  # Prevent going to sleep on AC - issues with CPU clocks on resume for a few minutes
  programs.plasma.powerdevil.AC.autoSuspend.action = "nothing";

  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium

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
