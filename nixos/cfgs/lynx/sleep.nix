{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
  minutes /*to seconds*/ = min: min * 60;
in
{
  # Stop logind from potentially messing with autosuspend
  logind.settings.Login.IdleAction = "ignore";

  autosuspend = {
    enable = true;

    settings = {
      idle_time = minutes 1;
      interval = minutes 1;
    };

    checks = {
      # Check for systemd inhibitors
      Inhibitors = {
        enable = true;
        class = "ExternalCommand";
        command = getExe (pkgs.writeShellApplication {
          name = "autosuspend-systemd-inhibit";
          runtimeInputs = with pkgs; [
            systemd
            gnugrep
          ];
          text = /*sh*/''
            systemd-inhibit --list --mode=block --no-legend |
              grep -q .
          '';
        });
      };

      # Don't sleep when SSH sessions are active
      RemoteUsers = {
        enable = true;
        class = "Users";
        host = ".+"; # Non-empty = remote
      };
    };
  };
}
