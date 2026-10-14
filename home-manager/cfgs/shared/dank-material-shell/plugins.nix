{ lib, cfg, pkgs, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # dankTranslate
      translate-shell

      # quickCapture
      gpu-screen-recorder
      wf-recorder
      ffmpeg
      imagemagick
      img2pdf
      tesseract
      zbar
    ];

    programs.dank-material-shell = {
      managePluginSettings = true;
      plugins = {
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

        quickCapture = {
          enable = true;
          settings = {
            showToolbar = true;
            defaultHideControlCenter = true;

            # Screenshots
            resetLastRegion = true;
            doneAction = "both"; # Copy & save
            saveDirectory = "~/Pictures/Screenshots";
            saveFilenamePattern = "Screenshot-%Y-%m-%d_%H-%M-%S";
            outputFormat = "png";
            color_palette_preset = "custom";
            toolbar_color_primary = "#ff00ee";
            toolbar_color_0 = "#dd0000";
            toolbar_color_1 = "#60dd00";

            # Recording
            recordingCodec = "auto";
            audioCodec = "opus";
            recordingDirectory = "~/Videos/Recordings";
            recordingFormat = "mp4";
            recordingFramerate = "60";
            recordingQuality = "high";
            recordingScreenTarget = "focused";
            recordSystemAudio = true;
          };
        };
      };
    };
  };
}
