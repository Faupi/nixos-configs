# Preset for auto-upgrades. 
# Off by default, targets the flake automatically. Does not commit, just keeps in sync with the remote.

{ pkgs, fop-utils, ... }:
let
  inherit (fop-utils) mkDefaultRecursively;
in
{
  system.autoUpgrade = mkDefaultRecursively rec {
    enable = false;
    upgrade = false;
    operation = "switch";
    flake = "github:faupi/nixos-configs?ref=master";
    flags = [
      "--no-update-lock-file" # NOTE: Keep upgrade = false!
      "--refresh"
    ];

    dates = rebootWindow.lower;
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
  };

  systemd = {
    timers.nixos-upgrade = {
      # Let the system wake up if suspended
      timerConfig = {
        WakeSystem = true;
      };
    };

    services.nixos-upgrade = {
      path = with pkgs; [
        curl
        bash
      ];

      # Important: Make sure that the flake is reachable
      # - Likely, the system will be offline for a while after waking up
      # - Also likely, GitHub could be down (sub-90% uptime achievement)
      # - We want to avoid rolling back to an older cached derivation.
      preStart = /*sh*/''
        echo "Waiting for connectivity..."

        timeout 300 bash -c '
          until curl -fsS https://api.github.com/repos/faupi/nixos-configs >/dev/null; do
            sleep 5
          done
        '

        echo "Able to reach remote flake repo, continuing."
      '';
    };
  };
}
