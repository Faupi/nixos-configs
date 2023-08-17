{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.steamdeck;
in {
  options.my.steamdeck = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    steam = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      user = mkOption {
        type = types.str;
        default = "deck";
      };
      bootSession = mkOption {
        type = types.str;
        default = "steam-wayland";
      };
      desktopSession = mkOption { 
        type = types.str;
        default = "steam-wayland";  # Placeholder, remember to override
      };
    };

    opensd = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      user = mkOption {
        type = types.str;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      jovian.devices.steamdeck.enable = true;
      
      # GPU setup
      services.xserver.videoDrivers = [ "amdgpu" ];
      boot.kernelParams = [ "iommu=pt" ];  # Hopefully fix GPU hanging randomly

      # Support for FreeSync monitors
      services.xserver.deviceSection = ''
        Option "VariableRefresh" "true"
      '';

      # Sounds are set up by Jovian NixOS
      hardware.pulseaudio.enable = mkIf
        (config.jovian.devices.steamdeck.enableSoundSupport && config.services.pipewire.enable)
        (mkForce false);

      # Firmware updaters
      services.fwupd.enable = true;
      environment.systemPackages = with pkgs; [
        steamdeck-firmware
        jupiter-dock-updater-bin
      ];
    })
    (mkIf (cfg.enable && cfg.opensd.enable) {
      users.groups.opensd = { };

      users.users."${cfg.opensd.user}".extraGroups = [ "opensd" ];

      services.udev.packages = [ pkgs.opensd ];

      # Enable OpenSD service
      home-manager.users."${cfg.opensd.user}".systemd.user.services.opensd = {
        Install = {
          WantedBy = [ "default.target" ];
        };

        Service = {
          ExecStart = "${pkgs.opensd}/bin/opensdd -l info";
        };
      };
    })
    (mkIf (cfg.enable && cfg.steam.enable) {
      services.xserver.displayManager.defaultSession = cfg.steam.bootSession;  # Still in effect with Jovian's dm

      jovian.steam = {
        enable = true;
        user = cfg.steam.user;
        # Session management
        autoStart = true;
        inherit ( cfg.steam ) desktopSession;
      };

      home-manager.users."${cfg.steam.user}".home.packages = with pkgs; [
        steam
        protonup
        lutris
      ];
    })
  ];
}
