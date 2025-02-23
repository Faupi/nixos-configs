{ homeUsers, ... }: {
  imports = [
    ./hardware.nix
    ./builder.nix

    # ./containers/minecraft-server
    # ./containers/minecraft-server-test
    # ./containers/vintage-story
  ];

  nix.distributedBuilds = false; # TEMP: Test if the builder unfucks itself

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade.enable = true; # Hands-free updates

  services.notify-email = {
    enable = true;
    recipient = "matej.sp583+homeserver@gmail.com";
    services = [ "nixos-upgrade" "nixos-store-optimize" ];
  };

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
