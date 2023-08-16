{ config, pkgs, lib, plasma-manager, ... }:
let
  ddcutil = "${pkgs.ddcutil}/bin/ddcutil --model \"24G1WG4\"";  # Targeted to external monitor
  monitorInputSwitcher = pkgs.writeShellScriptBin "switch-monitor-input" ''
    set -o nounset
    set -o errexit

    # Get current input
    current=$(${ddcutil} getvcp 60 | sed -n "s/.*(sl=\(.*\))/\1/p")

    # Get the other input
    case $current in

        # HDMI 1
        0x11)
            output=0x0f
            ;;

        # DisplayPort
        0x0f)
            output=0x11
            ;;

        *)
            echo "Unknown input"
            exit 1
            ;;
    esac

    # Set new input
    ${ddcutil} setvcp 60 $output
  '';
in
{
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = "KERNEL==\"i2c-[0-9]*\", GROUP+=\"users\"";

  environment.systemPackages = [
    monitorInputSwitcher  # TODO: Bind switch-monitor-input to a shortcut or whatever
  ];
}