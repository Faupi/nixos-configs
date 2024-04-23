{ homeUsers, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./network.nix
    ./steam.nix
    ./decky-plugins.nix
  ];

  # General 
  programs.dconf.enable = true;
  services.handheld-daemon = {
    enable = true;
    user = "faupi";
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  my = {
    plasma.enable = true;

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
    };
  };

  system.stateVersion = "23.11";
}
