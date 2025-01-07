{ homeUsers, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./network.nix
    ./steam.nix
    # ./vr
  ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  my = {
    plasma6.enable = true;
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
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
  ];

  system.stateVersion = "23.11";
}
