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
            # NOTE: Fonts should ideally be static, qC/Qt does not handle rendering variable weight well
            showToolbar = true;
            defaultHideControlCenter = true;

            # Recording
            recordingCodec = "auto";
            audioCodec = "opus";
            recordingDirectory = "~/Videos/Recordings";
            recordingFormat = "mp4";
            recordingFramerate = "60";
            recordingQuality = "high";
            recordingScreenTarget = "focused";
            recordSystemAudio = true;
            recordingSkipConfirm = false;

            # Screenshots
            resetLastRegion = true;
            doneAction = "both"; # Copy & save
            saveDirectory = "~/Pictures/Screenshots";
            saveFilenamePattern = "Screenshot-%Y-%m-%d_%H-%M-%S";
            outputFormat = "png";
            skipConfirm = false;

            # Screenshot editor
            modalDisplayMode = "modal"; # Show as an overlay
            show_shortcut_hints = true;
            editQuality = "600000"; # "Very High", default "Balanced" is pretty bad

            defaultPresetIndex = "0";
            defaultToolMode = "custom";
            defaultTool = "rect";

            color_palette_preset = "custom";
            toolbar_color_primary = "#ff00ee";
            toolbar_color_0 = "#dd0000";
            toolbar_color_1 = "#60dd00";

            defaultPenColor = "#ff00ee";
            defaultPenThickness = 4;
            defaultLineColor = "#ff00ee";
            defaultLineThickness = 4;
            defaultArrowColor = "#ff00ee";
            defaultArrowThickness = 4;
            defaultRectColor = "#ff00ee";
            defaultRectThickness = 4;
            defaultEllipseColor = "#ff00ee";
            defaultEllipseThickness = 4;
            defaultHighlighterColor = "primary";
            defaultHighlighterThickness = 8;
            roundHighlighter = true;
            defaultTextColor = "#ff00ee";
            textCornerRadius = 8;
            textFontFamily = "IBM Plex Sans";
            defaultStampColor = "#ff00ee";
            defaultStampSize = 6;
            stampFontFamily = "IBM Plex Sans";
            defaultCalloutZoom = 200;
          };
        };
      };
    };
  };
}
