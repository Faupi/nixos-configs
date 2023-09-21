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
      remotePlay.openFirewall = mkOption {
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

      # Missing SteamOS kernelParams
      boot.kernelParams = [
        "amd_iommu=off"  # Hopefully fix GPU hanging randomly
        "amdgpu.gttsize=8128"  # 8GB VRAM

        "tsc=directsync"  # Probably https://bugzilla.kernel.org/show_bug.cgi?id=202525 ?
        "module_blacklist=tpm"  # Second layer of "fuck TPM" :3
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

      # https://github.com/NixOS/nixpkgs/blob/4f77ea639305f1de0a14d9d41eef83313360638c/nixos/modules/programs/steam.nix#L141-L145
      networking.firewall = mkIf cfg.steam.remotePlay.openFirewall {
        allowedTCPPorts = [ 27036 ];
        allowedUDPPortRanges = [ { from = 27031; to = 27036; } ];
      };
    })
  ];
}
