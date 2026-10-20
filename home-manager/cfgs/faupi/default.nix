{ pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./moonlight.nix
  ];

  home.packages = with pkgs; [
    telegram-desktop

    winetricks
    wineWow64Packages.waylandFull

    (bottles.override { removeWarningPopup = true; })

    godot_4_7
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

    dank-material-shell = {
      plugins = {
        screenCaptureToolbar.settings.recordAudio = mkForce true;
      };
    };

    git = {
      settings = {
        user = {
          name = "Faupi";
          email = "matej.sp583@gmail.com";
        };
      };
    };
  };
}
