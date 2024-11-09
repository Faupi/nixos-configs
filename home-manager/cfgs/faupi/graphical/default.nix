{ pkgs, lib, fop-utils, ... }@args:
{
  home.packages = with pkgs;
    let
      # TODO: Why is this here (check https://github.com/lHumaNl/EchoWarp)
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
      SOCIALS.telegram-desktop
      # (blender.withPackages (py: [ py.py-slvs ]))

      # Gaming
      protontricks
      wineWowPackages.wayland
      unstable.libstrangle # Frame limiter

      moonlight-qt
      moonlight-mic-wrapper

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
