{ homeUsers, pkgs, fop-utils, lib, ... }:
{
  imports = [
    ./boot.nix
    ./handheld-daemon.nix
    ./hardware
    ./rollback-fix.nix
    ./sleep-hangup-fix.nix
    ./steam
    ./vr
  ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  flake-configs = {
    audio = {
      enable = true;
      user = "faupi";
    };

    plasma6.enable = true;

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autoStart = true;
      useSSHAgent = true;
    };

    monitor-input-switcher = {
      enable = false;
      user = "faupi";
    };
  };

  # User 
  users.users.faupi.extraGroups = [ "gamemode" "input" ];
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; }) ];
      home.packages = with pkgs; [
        openttd-jgrpp
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    cemu
    ukmm
    (fop-utils.wrapPkgBinary {
      inherit pkgs;
      package = pkgs.suyu;
      nameAffix = "amd";
      variables = {
        QT_QPA_PLATFORM = "xcb";
        AMD_VULKAN_ICD = "RADV";
      };
    })
  ];

  programs = {
    kdeconnect.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    flatpak.enable = true;
    fwupd.enable = true;
  };

  systemd = {
    services.steamos-manager = lib.mkForce { enable = false; };
    user.services.steamos-manager = lib.mkForce { enable = false; };
  };

  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";
}
