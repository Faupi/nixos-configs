{ pkgs, lib, fop-utils, ... }@args:
{
  imports = [
    ./moonlight.nix
  ];

  flake-configs = {
    discord.enable = true;
  };

  home.packages = with pkgs; [
    telegram-desktop
    # (blender.withPackages (py: [ py.py-slvs ]))

    # Gaming
    protontricks
    wineWowPackages.wayland
    unstable.libstrangle # Frame limiter

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

    plasma.workspace.wallpaper = builtins.fetchurl {
      url = "https://faupi.net/wallpaper-1.jpg";
      sha256 = "1k66a3wk3ayv18m2cvw8qlnj78xqz4aiv6pmm6nb4x4fildn7dd5";
    };
  };
}
