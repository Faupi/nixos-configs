{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.steamdeck;
  systemBin = "/run/current-system/sw/bin";

  # Gamescope switching
  wlsessions = "${config.services.xserver.displayManager.sessionData.desktops}/share/wayland-sessions";
  # TODO: Switch between Wayland and X11 depending on dock state

  setSessionToDesktop = pkgs.writeShellScriptBin "desktop-switch" ''
    sudo ${pkgs.tinydm}/bin/tinydm-set-session -f -s ${wlsessions}/plasmawayland.desktop
  '';
  # TODO: Revert to pkgs.writeShellScriptBin with yad added in before SDDM, or after SDDM, remake this into a custom package https://github.com/NixOS/nixpkgs/blob/68c599acd587f2e8e6e553711e061072ef8fc32d/pkgs/tools/archivers/rpmextract/default.nix#L10-L15

  setSessionToGamescope = pkgs.writeShellScriptBin "gamescope-switch" ''
    ${pkgs.yad}/bin/yad --center --title "Switch to Gaming Mode" --image "dialog-question" --buttons-layout=center --text "Are you sure you want to log out and switch?" --button=Switch:2 --button=Cancel:1
    answer=$?
    [[ $answer -ne 2 ]] && exit 0  # Exit if not confirmed

    sudo ${pkgs.tinydm}/bin/tinydm-set-session -f -s ${wlsessions}/steam-wayland.desktop
    ${systemBin}/qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 0 0
  '';
  steam-gamescope-switcher = pkgs.makeDesktopItem {
    name = "steam-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    exec = "${setSessionToGamescope}/bin/gamescope-switch";
    terminal = false;
    icon = "steamdeck-gaming-return";
    type = "Application";
    categories = [ "Game" "System" ];
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
      jovian.steam.enable = true;

      services.xserver.displayManager.defaultSession = "plasmawayland";  # TODO: Get Steam -> Plasma switch working and change default back to Steam

      home-manager.users."${cfg.steam.user}".home.packages = with pkgs; [
        steam
        steam-gamescope-switcher
        protonup
        lutris
      ];

      security.sudo.extraRules = [
        {
          users = [ "${cfg.steam.user}" ];
          commands = [
            {
              command = "${pkgs.tinydm}/bin/tinydm-set-session *";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    })
  ];
}
