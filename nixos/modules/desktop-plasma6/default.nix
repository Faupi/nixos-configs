{ config, pkgs, lib, ... }:
with lib;
let cfg = config.my.plasma6;
in {
  options.my.plasma6 = {
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
      services.desktopManager.plasma6 = {
        enable = true;
        notoPackage = pkgs.noto-fonts;
      };
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
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

      programs.dconf.enable = true;
    })
  ];
}
