{ config, pkgs, lib, ... }:

let
  # Percentages for points 1-10 (10°C to 100°C)
  # NOTE: Max 100%!
  fanPercentages = [ 44 48 55 60 71 79 87 95 100 100 ];

  # Convert percentages to 0-255 PWM values
  pwmValues = map (p: toString (builtins.div (p * 255) 100)) fanPercentages;

  applyFanCurve = pkgs.writeShellApplication {
    name = "apply-legion-fan-hwmon";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
    ];
    text = /*sh*/''
      # Find the correct hwmon directory by checking the 'name' file
      HWMON_PATH=""
      for h in /sys/class/hwmon/hwmon*; do
        if [ -f "$h/name" ] && [ "$(cat "$h/name")" = "legion_wmi_fan" ]; then
          HWMON_PATH="$h"
          break
        fi
      done

      if [ -z "$HWMON_PATH" ]; then
        echo "Error: legion_wmi_fan hwmon device not found!" >&2
        exit 1
      fi

      echo "Found Legion fan control at $HWMON_PATH"

      # Enable Manual Mode (Value 1)
      echo 1 > "$HWMON_PATH/pwm1_enable"

      # Apply the 10 points (10°C to 100°C)
      ${lib.concatStringsSep "\n" (lib.imap1 (i: v: ''
        echo ${v} > "$HWMON_PATH/pwm1_auto_point${toString i}_pwm"
      '') pwmValues)}

      echo "Fan curve applied successfully."
    '';
  };
in
{
  # Ensure the module is loaded
  boot = {
    extraModulePackages = [
      (pkgs.lenovo-legion-go-wmi-fan.override {
        inherit (config.boot.kernelPackages) kernel;
      })
    ];
    kernelModules = [ "lenovo-legion-go-wmi-fan" ];
  };

  # Service to apply the curve on boot
  systemd.services.legion-fan-hwmon = {
    description = "Apply Legion Go Custom Fan Curve (hwmon)";
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe applyFanCurve;
      User = "root";
    };
  };

  # Re-apply periodically to guard against resets.
  systemd.timers.legion-fan-hwmon = {
    description = "Re-apply Legion Go Custom Fan Curve (hwmon) every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "legion-fan-hwmon.service";
      OnBootSec = "10s";
      OnUnitActiveSec = "1min";
      Persistent = true;
    };
  };

  # Re-apply after waking up from sleep
  powerManagement.resumeCommands = lib.getExe applyFanCurve;

  # Add to system path so you can run it manually
  environment.systemPackages = [ applyFanCurve ];
}
