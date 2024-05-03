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
    plasma6.enable = true;

    steamdeck = {
      enable = true;
      gamescope = {
        enable = true;
        user = "faupi";
        desktopSession = "plasma";
      };
    };

    vintagestory = {
      client = {
        enable = false;
        user = "faupi";
      };
      mods.enable = true;
    };

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autostart.enable = true;
      useSSHAgent = true;
    };
  };

  programs.dconf.enable = true; # Needed for EasyEffects and similar

  environment.systemPackages = with pkgs;
    [
      waypipe # Cura remoting
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
        nur.repos.jpyke3.suyu-dev
      ];
    };
  };

  programs.kdeconnect.enable = true;

  networking.firewall = fop-utils.recursiveMerge [
    # Gamestreaming mic passthrough RTP 
    {
      allowedUDPPorts = [ 25000 ];
    }
    # LocalSend
    {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    }
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Autoload
  boot.kernelModules = [ "v4l2-loopback" ];

  system.stateVersion = "23.05";
}
