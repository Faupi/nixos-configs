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
              theme =
                let
                  themePkg = pkgs.catppuccin-sddm.override {
                    flavor = "mocha";
                    font = "Noto Sans";
                    fontSize = "9";
                    background = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
                    loginBackground = true;
                  };
                in
                "${themePkg}/share/sddm/themes/catppuccin-mocha-mauve";
              wayland.enable = true;
            };
          };
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

          environment.systemPackages = with pkgs; [
            mesa-demos # Enable OpenGL info integration

            # Let Ark deal with more filetypes
            p7zip
            unrar
          ] ++ (with pkgs.kdePackages; [
            kio-fuse # KDE IO handling for external drives and whatnot
            partitionmanager # Partition manager, nuff said

            qtsensors # Sensor compatibility (e.g. accelerometer for automatic screen rotation)

            kde-gtk-config
            dolphin-plugins # Git integration
            kdesdk-thumbnailers # PDF + Blender Thumbnails
          ]);

          programs.dconf.enable = true;
        }
      ]
    ))
  ];
}
