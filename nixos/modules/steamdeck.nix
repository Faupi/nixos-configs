{ config, lib, pkgs, ... }:
with lib;
let cfg = config.my.steamdeck;
in {
  options.my.steamdeck = {
    enable = mkEnableOption "Steamdeck-specific setup";

    gamescope = {
      enable = mkEnableOption "Jovian Steam gamescope session";
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
        default = "steam-wayland"; # Placeholder, remember to override
      };
    };

    opensd = {
      enable = mkEnableOption "Userspace driver for Valve's Steam Deck";
      user = mkOption { type = types.str; };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      jovian = {
        hardware.has.amd.gpu = true;
        devices.steamdeck = {
          enable = true;
          enableXorgRotation = false; # Unfix X11 rotation (drivers fix it)
          enableDefaultCmdlineConfig = true;
          autoUpdate = false;
        };
        steamos = {
          useSteamOSConfig = false;

          # Cherry-pick changes
          enableDefaultCmdlineConfig = true;
          enableMesaPatches = false;
          enableVendorRadv = false;
        };
      };

      services.libinput = {
        enable = true;
      };

      # GPU setup
      services.xserver.videoDrivers = [ "amdgpu" ];

      # Missing SteamOS kernelParams
      boot.kernelParams = [
        "tsc=directsync" # Probably https://bugzilla.kernel.org/show_bug.cgi?id=202525 ?
        "module_blacklist=tpm" # Second layer of "fuck TPM" :3
        "spi_amd.speed_dev=1"
      ];

      # Fix random hangs possibly?
      hardware.cpu.amd.updateMicrocode = true;

      # Enable OpenGL
      hardware.graphics = {
        enable = true;
      };

      # Ignore built-in trackpad as a desktop input
      services.udev.extraRules = ''
        KERNEL=="event[0-9]*", ATTRS{phys}=="usb-0000:04:00.4-3/input0", TAG+="kwin-ignore-tablet-mode"
        KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
      '';

      # Sounds are set up by Jovian NixOS, so we don't want base pulseaudio
      hardware.pulseaudio.enable = mkIf
        (config.jovian.devices.steamdeck.enableSoundSupport
          && config.services.pipewire.enable)
        (mkForce false);

      # Firmware updaters
      services.fwupd.enable = true;
      environment.systemPackages = with pkgs; [
        steamdeck-firmware
        jupiter-dock-updater-bin
        plasmadeck-vapor-theme
      ];
    })
    (mkIf (cfg.enable && cfg.opensd.enable) {
      users.groups.opensd = { };

      users.users."${cfg.opensd.user}".extraGroups = [ "opensd" ];

      services.udev.packages = [ pkgs.opensd ];

      # Enable OpenSD service
      home-manager.users."${cfg.opensd.user}".systemd.user.services.opensd = {
        Install = { WantedBy = [ "default.target" ]; };

        Service = { ExecStart = "${getExe pkgs.opensd} -l info"; };
      };
    })
    (mkIf (cfg.enable && cfg.gamescope.enable) {
      services.displayManager.defaultSession = cfg.gamescope.bootSession; # Still in effect with Jovian's dm

      jovian = {
        steam = {
          enable = true;
          user = cfg.gamescope.user;
          # Session management
          autoStart = true;
          inherit (cfg.gamescope) desktopSession;
        };
        decky-loader = {
          enable = true;
          user = "root"; # https://github.com/Jovian-Experiments/Jovian-NixOS/blob/1171169117f63f1de9ef2ea36efd8dcf377c6d5a/modules/decky-loader.nix#L80-L84
          extraPackages = with pkgs; [
            curl
            unzip
            util-linux
            gnugrep

            readline.out
            procps
            pciutils
            libpulseaudio
          ];
        };
      };

      programs.steam = {
        enable = true;
        extest.enable = true; # X11->Wayland SteamInput mapping
        remotePlay.openFirewall = true;
      };

      # Since extest fixes the keyboard on Wayland, we probably want autostart for Steam
      environment.systemPackages = [
        (pkgs.makeAutostartItem rec {
          name = "steam";
          package = pkgs.makeDesktopItem {
            inherit name;
            desktopName = "Steam";
            exec = "steam -silent %U";
            icon = "steam";
            extraConfig = {
              OnlyShowIn = "KDE";
            };
          };
        })
      ];

      home-manager.users."${cfg.gamescope.user}".home.packages = with pkgs; [
        unstable.steamtinkerlaunch
        unstable.protonup-qt

        unstable.mangohud
      ];
    })
  ];
}
