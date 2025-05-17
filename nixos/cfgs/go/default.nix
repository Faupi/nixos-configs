{ homeUsers, pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./handheld-daemon.nix
    ./hardware
    ./steam
    # ./vr
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
      enable = true;
      user = "faupi";
    };
  };

  # User 
  users.users.faupi.extraGroups = [ "gamemode" ];
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; }) ];
      home.packages = with pkgs; [
        openttd-jgrpp
      ];
    };
  };

  programs = {
    kdeconnect.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
  ];

  services.fwupd.enable = true;
  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";
}
