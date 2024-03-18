{ pkgs, lib, ... }:
{
  home.packages = with pkgs;
    let
      moonlight-mic-wrapper-script = pkgs.writeShellScript "moonlight-mic-wrapper" ''
        trap 'kill %1' SIGINT
        pw-cli -m load-module libpipewire-module-vban-send local.ifname="enp4s0f3u1u4c2" destination.ip="$(${lib.getExe pkgs.dig} +short faupi-pc.local)" destination.port=6980 sess.name="Deck" sess.media="audio" & 
        ${lib.getExe pkgs.moonlight-qt}
      '';

      moonlight-mic-wrapper = pkgs.makeDesktopItem {
        name = "com.moonlight_stream.Moonlight-Mic";
        comment = "Stream games from your NVIDIA GameStream-enabled PC";
        desktopName = "Moonlight (with mic)";
        exec = toString moonlight-mic-wrapper-script;
        terminal = false;
        icon = "moonlight";
        type = "Application";
        categories = [ "Qt" "Game" ];
        keywords = [ "nvidia" "gamestream" "stream" ];
      };
    in
    [
      mpv
      localsend
      SOCIALS.telegram-desktop
      # cad-blender

      # Gaming
      protontricks
      wineWowPackages.wayland
      grapejuice # Roblox
      unstable.libstrangle # Frame limiter

      moonlight-qt
      moonlight-mic-wrapper
    ];


  programs = {
    firefox.profiles.faupi.isDefault = true;

    # TODO: Move away from hm setup for 1P
    _1password = {
      enable = true;
      package = pkgs._1password-gui;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
        obs-vaapi
      ];
    };
  };

  services = {
    kdeconnect = {
      # NOTE: Needs open firewall TCP+UDP 1714-1764
      enable = true;
      indicator = true;
    };
  };
}
