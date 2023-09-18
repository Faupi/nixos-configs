{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.cura;
in
{
  options.my.cura = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    x11Forwarding.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = (mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.cura
    ];
  });
}
