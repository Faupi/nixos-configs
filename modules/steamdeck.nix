{ config, lib, pkgs, fop-utils, ... }:
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
      jovian.devices.steamdeck = {
        enable = true;
        enableXorgRotation = false; # Unfix X11 rotation (drivers fix it)
      };

      services.xserver.libinput = {
        enable = true;
      };

      # GPU setup
      services.xserver.videoDrivers = [ "amdgpu" ];

      # Missing SteamOS kernelParams
      boot.kernelParams = [
        "amd_iommu=off" # Hopefully fix GPU hanging randomly
        "amdgpu.gttsize=8128" # 8GB VRAM

        "tsc=directsync" # Probably https://bugzilla.kernel.org/show_bug.cgi?id=202525 ?
        "module_blacklist=tpm" # Second layer of "fuck TPM" :3
        "spi_amd.speed_dev=1"
      ];

      # Fix random hangs possibly?
      hardware.cpu.amd.updateMicrocode = true;

      # Enable OpenGL
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };

      # Support for FreeSync monitors
      services.xserver.deviceSection = ''
        Option "VariableRefresh" "true"
      '';

      # Ignore built-in trackpad as a desktop input
      services.udev.extraRules = ''
        KERNEL=="event[0-9]*", ATTRS{phys}=="usb-0000:04:00.4-3/input0", TAG+="kwin-ignore-tablet-mode"
        KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
      '';

      # Sounds are set up by Jovian NixOS
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

        Service = { ExecStart = "${pkgs.opensd}/bin/opensdd -l info"; };
      };
    })
    (mkIf (cfg.enable && cfg.gamescope.enable) {
      services.xserver.displayManager.defaultSession =
        cfg.gamescope.bootSession; # Still in effect with Jovian's dm

      jovian = {
        devices.steamdeck = {
          # TODO: Resolve when patching of mesa on Jovian is fixed
          enableMesaPatches = false;
          enableVendorRadv = false;
        };
        steam = {
          enable = true;
          user = cfg.gamescope.user;
          # Session management
          autoStart = true;
          inherit (cfg.gamescope) desktopSession;
        };
      };

      programs.steam = {
        enable = true;
        package = pkgs.steam.override {
          # Fix input mapping on Wayland
          extraEnv.LD_PRELOAD = "${pkgs.extest}/lib/libextest.so";
        };
        remotePlay.openFirewall = true;
      };

      # Since extest fixes the keyboard on Wayland, we probably want autostart for Steam
      environment.etc."Steam autostart" = fop-utils.makeAutostartItemLink pkgs
        {
          name = "steam";
          desktopName = "Steam";
          exec = "steam -silent %U";
          icon = "steam";
          extraConfig = {
            OnlyShowIn = "KDE";
          };
        }
        {
          delay = 5;
        };

      home-manager.users."${cfg.gamescope.user}".home.packages = with pkgs; [
        unstable.steamtinkerlaunch
        unstable.protonup-qt

        unstable.mangohud
      ];
    })
  ];
}
