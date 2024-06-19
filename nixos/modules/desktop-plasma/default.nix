{ config, pkgs, lib, ... }:
with lib;
let cfg = config.my.plasma;
in {
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
        excludePackages = [ pkgs.xterm ];
      };

      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        xdgOpenUsePortal = true;
      };

      # Desktop
      services.xserver.desktopManager.plasma5 = {
        enable = true;
        runUsingSystemd = true; # Fix for autostart issues
      };
      environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        oxygen
        khelpcenter
        print-manager
      ];
      environment.sessionVariables = {
        GTK_USE_PORTAL = "1";
      };

      # Let Ark deal with more filetypes
      environment.systemPackages = with pkgs; [
        p7zip
        unrar
        kio-fuse
      ];

      # Fonts
      fonts.packages = with pkgs; [ noto-fonts ];

      programs.dconf.enable = true;
    })
  ];
}
