{ homeUsers, ... }: {
  imports = [
    ./hardware.nix
    ./builder.nix

    # ./containers/minecraft-server
    # ./containers/minecraft-server-test
    # ./containers/vintage-story
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade.enable = true; # Hands-free updates

  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = false; }) ];
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
