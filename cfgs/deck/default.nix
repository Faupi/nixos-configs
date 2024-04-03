{ config, pkgs, lib, fop-utils, homeUsers, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./secondary-panel.nix
    ./external-display
  ];

  services.openssh.enable = true;

  networking.networkmanager.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  my = {
    plasma = { enable = true; };
    steamdeck = {
      enable = true;
      gamescope = {
        enable = true;
        user = "faupi";
        desktopSession = "plasmawayland";
      };
    };
    vintagestory = {
      client = {
        enable = false;
        user = "faupi";
      };
      mods.enable = true;
    };
  };

  programs.dconf.enable = true; # Needed for EasyEffects and similar

  environment.systemPackages = with pkgs;
    [
      waypipe # Cura remoting
      kio-fuse
    ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    disabledPlugins = [ "sap" ];
  };

  # User 
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; }) ];

      home.packages = with pkgs; let
        steam-fetch-artwork = writeShellScriptBin "steam-fetch-artwork" ''
          ${coreutils}/bin/yes "" | ${getExe steamgrid} -steamdir ~/.steam/steam -nonsteamonly -onlymissingartwork -steamgriddb "$(<${config.sops.secrets.steamgrid-api-key.path})"
        '';
      in
      [
        steam-fetch-artwork
        prismlauncher-qt5
      ];
    };
  };

  programs.kdeconnect.enable = true;

  # Add wrappers for 1Password
  programs._1password-gui = {
    enable = true;
    package = config.home-manager.users.faupi.programs._1password.package;
  };

  networking.firewall = fop-utils.recursiveMerge [
    # Gamestreaming mic passthrough RTP 
    {
      allowedUDPPorts = [ 25000 ];
    }
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Autoload
  boot.kernelModules = [ "v4l2-loopback" ];

  system.stateVersion = "23.05";
}
