{ lib, ... }:
{
  programs.plasma = {
    powerdevil = {
      general = {
        pausePlayersOnSuspend = false;
      };
      AC = {
        powerButtonAction = "sleep";
      };
      battery = {
        powerButtonAction = "sleep";
      };
      lowBattery = {
        powerButtonAction = "sleep";
        powerProfile = "powerSaving";
      };
    };

    configFile = {
      powerdevilrc = {
        Inhibitions = {
          BlockedInhibitions = lib.concatStringsSep "," [
            "Steam:Client interface" # Steam does this at random in the tray
          ];
        };
      };
    };
  };
}
