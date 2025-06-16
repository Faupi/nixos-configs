{ pkgs, lib, fop-utils, ... }@args:
{
  imports = [
    ./moonlight.nix
  ];

  flake-configs = {
    discord.enable = true;
    blender.enable = true;
  };

  home.packages = with pkgs; [
    telegram-desktop

    winetricks
    wineWowPackages.waylandFull

    unstable.libstrangle
    bottles
  ];

  programs = {
    zen-browser = {
      enable = true;
      profiles.faupi = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/faupi.nix" args) // { isDefault = true; };
    };

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
