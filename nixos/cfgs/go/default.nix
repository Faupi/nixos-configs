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
  services.handheld-daemon = {
    enable = true;
    user = "faupi";
    package = with pkgs; handheld-daemon.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
        pkgs.adjustor
      ];
    });
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

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
