{ pkgs, ... }:
let
  ddcutil = ''${pkgs.ddcutil}/bin/ddcutil --model "24G1WG4"''; # Targeted to external monitor
  monitorInputSwitcher = pkgs.writeShellScriptBin "switch-monitor-input" ''
    set -o nounset
    set -o errexit

    cachepath='/tmp/monitor-input.txt'

    if [ -f "$cachepath" ]; then
      # Get current input from cache if available
      current=$(< $cachepath)
    else
      # Get current from monitor
      current=$(${ddcutil} getvcp 60 | sed -n "s/.*(sl=\(.*\))/\1/p")
    fi

    if [ "$#" -eq "0" ]; then
      # If no arguments are passed, get the other input
      case $current in

        # HDMI 1 -> DisplayPort
        0x11)
          output=0x0f
          ;;

        # DisplayPort -> HDMI 1
        0x0f)
          output=0x11
          ;;

        *)
          echo "Unknown input"
          exit 1
          ;;
      esac
    else
      # Get output from argument
      output=$1
    fi

    if [[ $output == $current ]]; then
      exit 0  # Nothing to do here, output stays the same
    fi

    # Write cache
    printf '%s' "$output" > "$cachepath"

    # Set new input
    ${ddcutil} setvcp 60 $output
  '';
in
{
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''KERNEL=="i2c-[0-9]*", GROUP+="users"'';

  environment.systemPackages = [ monitorInputSwitcher ];
}
