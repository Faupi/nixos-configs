{ lib, cfg, ... }:
{
  config = lib.mkIf cfg.enable {
    programs.plasma.configFile = {
      spectaclerc = {
        GuiConfig = {
          # NOTE: These are the quick options visible directly in GUI
          includePointer = true;
          includeShadow = false; # Window shadows - mostly they're just annoying
          quitAfterSaveCopyExport = true;
        };

        General = {
          clipboardGroup = "PostScreenshotCopyImage"; # Copy screenshots to clipboard automatically
          launchAction = "TakeFullscreenScreenshot"; # Not taking one fucks the layout which is confusing
          useReleaseToCapture = true;
          autoSaveImage = false; # Do not save image if it's copied
          rememberSelectionRect = "Never";
        };

        ImageSave = {
          preferredImageFormat = "PNG";
          imageFilenameTemplate = "<yyyy>-<MM>-<dd>_<HH>-<mm>";
        };
        VideoSave = {
          preferredVideoFormat = 2; # MP4
          videoFilenameTemplate = "<yyyy>-<MM>-<dd>_<HH>-<mm>";
        };

        Annotations = {
          lineShadow = false;
          rectangleShadow = false;
        };
      };
    };
  };
}
