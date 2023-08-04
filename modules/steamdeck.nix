{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.steamdeck;
  systemBin = "/run/current-system/sw/bin";

  # Gamescope switching
  setSessionScript = pkgs.writeShellScriptBin "set-session" ''
    ${systemBin}/sed -i -e "s|^Session=.*|Session=$1|" /var/lib/AccountsService/users/${cfg.steam.user}
    exit 0
  '';
  # TODO: Switch between Wayland and X11 depending on dock state
  setSessionToDesktop = pkgs.writeShellScriptBin "desktop-switch" ''
    ${pkgs.sudo}/bin/sudo ${setSessionScript}/bin/set-session plasmawayland
    exit 0
  '';
  # TODO: Revert to pkgs.writeShellScriptBin with yad added in before SDDM, or after SDDM, remake this into a custom package https://github.com/NixOS/nixpkgs/blob/68c599acd587f2e8e6e553711e061072ef8fc32d/pkgs/tools/archivers/rpmextract/default.nix#L10-L15

  setSessionToGamescope = pkgs.writeShellScriptBin "gamescope-switch" ''
    ${pkgs.yad}/bin/yad --center --title "Switch to Gaming Mode" --image "dialog-question" --buttons-layout=center --text "Are you sure you want to log out and switch?" --button=Switch:2 --button=Cancel:1
    answer=$?
    [[ $answer -ne 2 ]] && exit 0  # Exit if not confirmed

    ${pkgs.sudo}/bin/sudo ${setSessionScript}/bin/set-session steam-wayland
    ${systemBin}/qdbus org.kde.Shutdown /Shutdown logout
    ${systemBin}/watch -g loginctl list-sessions  # Wait for logout to finish
    ${pkgs.sudo}/bin/sudo ${systemBin}/systemctl restart display-manager  # Trigger auto-login by GDM restart
    exit 0
  '';
  steam-gamescope-switcher = pkgs.makeDesktopItem {
    name = "steam-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    exec = "${setSessionToGamescope}/bin/gamescope-switch";
    terminal = false;
    icon = "steamdeck-gaming-return";
    type = "Application";
    categories = [ "Game" ];
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

      services.xserver.displayManager.defaultSession = "steam-wayland";

      home-manager.users."${cfg.steam.user}".home.packages = with pkgs; [
        steam
        steam-gamescope-switcher
        protonup
        lutris
      ];

      # Gamescope-switcher hook
      environment.etc = {
        # Set target session to desktop after every login
        "gdm/PreSession/Default".source = "${setSessionToDesktop}/bin/desktop-switch";
      };

      security.sudo.extraRules = [
        {
          users = [ "${cfg.steam.user}" ];
          commands = [
            {
              command = "${setSessionScript}/bin/set-session *";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${systemBin}/systemctl restart display-manager";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    })
  ];
}
