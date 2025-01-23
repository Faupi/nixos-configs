{ config, pkgs, lib, fop-utils, homeUsers, ... }:
with lib;
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./secondary-panel.nix
  ];

  services.openssh.enable = true;

  networking.networkmanager.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  services.displayManager.sddm.enable = false; # Managed by Jovian

  # Module configurations
  flake-configs = {
    plasma6.enable = true;

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autoStart = true;
      useSSHAgent = true;
    };
  };

  my = {
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
  };

  programs = {
    kdeconnect.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

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

      home.packages = with pkgs; [
        prismlauncher
        nur.repos.jpyke3.suyu-dev
      ];
    };
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
