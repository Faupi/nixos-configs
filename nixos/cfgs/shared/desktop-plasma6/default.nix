{ config, pkgs, lib, fop-utils, ... }:
let
  cfg = config.flake-configs.plasma6;
in
{
  options.flake-configs.plasma6 = {
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
          xdg.portal.xdgOpenUsePortal = true;

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

          environment.systemPackages = with pkgs; with kdePackages; [
            # Let Ark deal with more filetypes
            p7zip
            unrar

            kio-fuse # KDE IO handling for external drives and whatnot
            partitionmanager # Partition manager, nuff said

            qtsensors # Sensor compatibility (e.g. accelerometer for automatic screen rotation)
          ];

          programs.dconf.enable = true;
        }
      ]
    ))
  ];
}
