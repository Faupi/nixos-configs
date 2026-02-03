{ lib, cfg, fop-utils, ... }:
let
  minutes = sec: sec * 60;
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma = {
      powerdevil = fop-utils.mkDefaultRecursively {
        general = {
          pausePlayersOnSuspend = false;
        };

        batteryLevels = {
          lowLevel = 10;
          criticalLevel = 5;
          criticalAction = "hibernate"; # Should be fine even for systems without hibernation
        };

        AC = {
          powerProfile = "performance";
          powerButtonAction = "sleep";
          autoSuspend = {
            idleTimeout = minutes 15;
            action = "sleep";
          };
          displayBrightness = null;
          dimDisplay = {
            enable = true;
            idleTimeout = minutes 5;
          };
          turnOffDisplay.idleTimeout = "never";
        };

        battery = {
          powerProfile = "balanced";
          powerButtonAction = "sleep";
          autoSuspend = {
            idleTimeout = minutes 5;
            action = "sleep";
          };
          displayBrightness = null;
          dimDisplay = {
            enable = true;
            idleTimeout = minutes 2;
          };
          turnOffDisplay.idleTimeout = "never";
        };

        lowBattery = {
          powerProfile = "powerSaving";
          powerButtonAction = "sleep";
          autoSuspend = {
            idleTimeout = minutes 2;
            action = "sleep";
          };
          displayBrightness = 30;
          dimDisplay = {
            enable = true;
            idleTimeout = minutes 1;
          };
          turnOffDisplay.idleTimeout = "never";
        };
      };

      configFile = {
        powerdevilrc = {
          Inhibitions = {
            BlockedInhibitions = lib.concatStringsSep "," [
              "Steam:Client interface" # Steam does this at random in the tray
            ];
          };

          # TODO: Send PR for upstream fix (null sets null option instead of false)
          "AC/Display".UseProfileSpecificDisplayBrightness = false;
          "Battery/Display".UseProfileSpecificDisplayBrightness = false;
        };
      };
    };
  };
}
