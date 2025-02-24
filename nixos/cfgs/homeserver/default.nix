{ config, homeUsers, ... }: {
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

  sops.secrets.notify-email-token = {
    sopsFile = ./secrets.yaml;
    mode = "0440";
    restartUnits = [ "notify-email@.service" ]; # Honestly not sure if this is right
  };
  services.notify-email = {
    enable = true;
    tokenPath = config.sops.secrets.notify-email-token.path;
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
