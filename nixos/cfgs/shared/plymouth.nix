{ lib, config, ... }:
let
  cfg = config.flake-configs.plymouth;
in
{
  options = {
    flake-configs.plymouth = {
      enable = lib.mkEnableOption "Plymouth";
    };
  };

  config = (lib.mkIf cfg.enable {
    boot = {
      plymouth.enable = true;

      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
      initrd = {
        verbose = false;
        systemd.enable = true;
      };
    };
  });
}
