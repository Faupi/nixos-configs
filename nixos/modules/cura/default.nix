{ config, lib, pkgs, ... }:
with lib;
let cfg = config.my.cura;
in {
  options.my.cura = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = (mkIf cfg.enable {

    # Enable OpenGL
    hardware.opengl = {
      enable = true;
      extraPackages = [ pkgs.mesa.drivers ];
    };

    environment.systemPackages = [ pkgs.cura ];

  });
}
