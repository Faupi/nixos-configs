{ config, pkgs, lib, ... }:
with lib;
let 
  cfg = config.my.plasma;
in
{
  options.my.plasma = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Display
      services.xserver = {
        enable = true;
        excludePackages = [ 
          pkgs.xterm
        ];
      };

      # Desktop
      services.xserver.desktopManager.plasma5.enable = true;
      environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        oxygen
        khelpcenter
        print-manager
      ];

      # Fonts
      fonts.fonts = with pkgs; [
        noto-fonts
      ];
    })
  ];
}
