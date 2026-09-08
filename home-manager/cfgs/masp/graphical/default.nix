{ config, pkgs, ... }:
{
  imports = [
    ./clipboard-actions.nix
  ];

  flake-configs = {
    clipboard-actions.enable = true;
    dank-material-shell.enable = true;

    dolphin = {
      enable = true;
      setAsDefault = true;
    };

    # TODO: Nuke when migrated
    vivaldi = {
      enable = true;
      setAsDefault = false;
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
    };

    zen = {
      enable = true;
      setAsDefault = true;
    };
  };

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
