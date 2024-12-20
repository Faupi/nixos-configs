{ config, pkgs, lib, ... }:
{
  options.programs.openvpn3.indicator = {
    enable = lib.mkEnableOption "OpenVPN3 system tray indicator";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.openvpn3-indicator;
    };
    autoStart = lib.mkEnableOption "Start with system";
  };

  config =
    let
      cfg = config.programs.openvpn3.indicator;

      # Link the indicator to the main OpenVPN3 client just in case
      linkedPkg = cfg.package.overrideAttrs (oldAttrs: {
        openvpn3 = config.programs.openvpn3.package;
      });
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        linkedPkg
        (lib.mkIf cfg.autoStart (
          pkgs.makeAutostartItem {
            name = "net.openvpn.openvpn3_indicator";
            package = linkedPkg;
          }
        ))
      ];
    };
}
