{ pkgs, homeUsers, ... }: {
  imports = [
    ./hardware.nix
    ./builder.nix

    ./containers/minecraft-server
    ./containers/minecraft-server-test
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade.enable = true; # Hands-free updates

  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = false; }) ];
    };
  };

  # Cura
  services.openssh.settings.X11Forwarding = true;
  environment.systemPackages = [ pkgs.waypipe ];
  my = {
    cura.enable = true; # Remoted via X11 forwarding
    vintagestory = {
      server.enable = false;
      mods.enable = true;
    };
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };
  system.stateVersion = "22.11";
}
