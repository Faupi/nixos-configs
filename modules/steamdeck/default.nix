{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.steamdeck;
  
  # Gamescope switching
  desktopSetSessionScript = pkgs.writeScriptBin "set-session" ''
    #! ${pkgs.bash}/bin/sh
    /run/current-system/sw/bin/sed -i -e "s|^Session=.*|Session=$1|" /var/lib/AccountsService/users/faupi
    exit 0
  '';
  desktopSessionScript = pkgs.writeScriptBin "desktop-switch" ''
    #! ${pkgs.bash}/bin/sh
    /run/wrappers/bin/sudo ${desktopSetSessionScript}/bin/set-session plasma
    exit 0
  '';
  gamescopeSessionScript = pkgs.writeScriptBin "gamescope-switch" ''
    #! ${pkgs.bash}/bin/sh
    /run/wrappers/bin/sudo ${desktopSetSessionScript}/bin/set-session steam-wayland
    /run/current-system/sw/bin/qdbus org.kde.Shutdown /Shutdown logout
    exit 0
  '';
  steam-gamescope-switcher = pkgs.makeDesktopItem {
    name = "steam-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    exec = "${gamescopeSessionScript}/bin/gamescope-switch";
    terminal = false;
    icon = "steam";
    type = "Application";
  };
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
      
      services.xserver.videoDrivers = [ "amdgpu" ];

      # Sounds are set up by Jovian NixOS
      hardware.pulseaudio.enable = mkIf
        (config.jovian.devices.steamdeck.enableSoundSupport && config.services.pipewire.enable)
        (mkForce false);

      # Firmware updaters
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
      jovian.steam.enable = true;

      services.xserver.displayManager.defaultSession = "steam-wayland";

      home-manager.users."${cfg.steam.user}".home.packages = with pkgs; [
        steam
        steam-gamescope-switcher
        protonup
        lutris
      ];
    })
  ];
}
