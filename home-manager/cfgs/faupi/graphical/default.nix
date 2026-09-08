{ pkgs, ... }:
{
  imports = [
    ./moonlight.nix
  ];

  flake-configs = {
    blender.enable = true;
    clipboard-actions.enable = true;
    dank-material-shell.enable = true;
    konsole.enable = true;
    unityhub.enable = true;

    dolphin = {
      enable = true;
      setAsDefault = true;
    };

    vscodium = {
      enable = true;
      setAsDefault = true;
      folderHandling.enable = true;
    };

    zen = {
      enable = true;
      setAsDefault = true;
    };
  };

  home.packages = with pkgs; [
    telegram-desktop

    winetricks
    wineWow64Packages.waylandFull

    (bottles.override { removeWarningPopup = true; })
  ];

  programs = {
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        # obs-vkcapture # TODO: Infinitely hangs on checks - https://github.com/NixOS/nixpkgs/issues/349053
        obs-vaapi
      ];
    };
  };
}
