{ homeUsers, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./network.nix
    ./steam.nix
    # ./vr
  ];

  # General 
  programs.dconf.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  flake-configs = {
    plasma6.enable = true;
  };

  my = {
    localsend.enable = true;

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autostart.enable = true;
      useSSHAgent = true;
    };
  };

  # User 
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
  };

  # SPT
  networking.firewall = {
    allowedTCPPorts = [
      25565
    ];
    allowedUDPPorts = [
      25565
    ];
  };

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
  ];

  system.stateVersion = "23.11";
}
