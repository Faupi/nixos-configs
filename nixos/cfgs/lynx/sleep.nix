{ lib, pkgs, ... }:
let
  inherit (lib) getExe;
  minutes /*to seconds*/ = min: min * 60;
  seconds = sec: sec;
in
{
  services = {
    # Stop logind from potentially messing with autosuspend
    logind.settings.Login.IdleAction = "ignore";

    autosuspend = {
      enable = true;

      settings = {
        idle_time = minutes 15;
        interval = seconds 30;
      };

      checks = {
        # TODO: Add inhibition for Steam updates

        # Check for systemd inhibitors
        Inhibitors = {
          enable = true;
          class = "ExternalCommand";
          command = getExe (pkgs.writeShellApplication {
            name = "autosuspend-check-systemd-inhibit";
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

        # NixOS auto-upgrade
        AutoUpgrade = {
          enable = true;
          class = "ExternalCommand";
          command = getExe (pkgs.writeShellApplication {
            name = "autosuspend-check-systemd-autoupgrade";
            runtimeInputs = with pkgs; [
              systemd
            ];
            text = /*sh*/''
              systemctl is-active --quiet nixos-upgrade.service
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
  };
}
