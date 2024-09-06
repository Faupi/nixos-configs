{ config, pkgs, lib, fop-utils, ... }:
let
  cfg = config.my.plasma6;
in
{
  options.my.plasma6 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable (
      fop-utils.recursiveMerge [
        # Display
        {
          services = {
            xserver = {
              enable = true;
              excludePackages = [ pkgs.xterm ];
            };
            displayManager.sddm = {
              enable = lib.mkDefault true;
              theme = "catppuccin-mocha";
              wayland.enable = true;
            };
          };

          environment.systemPackages = [
            (pkgs.catppuccin-sddm.override {
              flavor = "mocha";
              font = "Noto Sans";
              fontSize = "9";
              background = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
              loginBackground = true;
            })
          ];
        }

        # Desktop
        {
          xdg.portal = {
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
            xdgOpenUsePortal = true;
          };

          services.displayManager.defaultSession = lib.mkDefault "plasma";

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
            kate
          ];
          environment.sessionVariables = {
            GTK_USE_PORTAL = "1";
          };

          environment.systemPackages = with pkgs; with kdePackages; [
            # Let Ark deal with more filetypes
            p7zip
            unrar

            kio-fuse # KDE IO handling for external drives and whatnot
            partitionmanager # Partition manager, nuff said
          ];

          programs.dconf.enable = true;
        }
      ]
    ))
  ];
}
