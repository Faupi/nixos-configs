{ homeUsers, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./network.nix
    ./steam.nix
    ./vr
  ];

  # General 
  programs.dconf.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # TODO: Propagate across every device EXCEPT for the same builder - probably needs to be in flake.nix
  nix.settings.substituters = [
    "ssh-ng://nixremote@homeserver.local"
  ];

  # Module configurations
  my = {
    plasma6.enable = true;
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
