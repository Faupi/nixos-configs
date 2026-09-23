{ lib, cfg, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # dankTranslate
      translate-shell

      # screenCaptureToolbar
      gpu-screen-recorder
      slurp
      grim
      wl-clipboard
      satty
      ffmpeg
      pipewire
      pulseaudio
    ];

    programs.dank-material-shell = {
      managePluginSettings = true;
      plugins = {
        dankBatteryAlerts.enable = true;
        dankKDEConnect.enable = true;
        emojiLauncher.enable = true;

        calculator = {
          enable = true;
          settings = {
            trigger = "=";
          };
        };

        # Third-party (NOTE: sources are mapped from the official module)
        amdGpuMonitorRevive = {
          enable = true;
          settings = {
            minimumWidth = true; # Otherwise VRAM often gets ellipsed
            popoutStyle = "dmsExtended";
          };
        };

        dankTranslate = {
          enable = true;
          settings = {
            trigger = ">";
          };
        };

        screenCaptureToolbar = {
          enable = true;
          settings = {
            showPointer = true;
            copyPathOnCapture = true;

            format = "png";
            customPath = "~/Pictures/Screenshots";

            videoFPS = "60";
            videoFormat = "mp4";
            videoQuality = "high";
            videoCustomPath = "~/Videos/Screencasts";
            recordAudio = false;
            recordMic = false;
            showRecPill = true;
          };
        };
      };
    };
  };
}
