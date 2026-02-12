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
              extraPackages = [ pkgs.sddm-astronaut-faupi ]; # deps for themes
              theme = "${pkgs.sddm-astronaut-faupi}/share/sddm/themes/sddm-astronaut-theme";
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

        # Auth
        {
          # Enable KWallet unlock on user login
          security.pam.services.sddm.kwallet.enable = true;
        }
      ]
    ))
  ];
}
