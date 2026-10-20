{ ... }: {
  imports = [
    ./builder
    ./hardware.nix
    ./notify-email.nix

    # ./containers/octoprint
    # ./containers/minecraft-server
    # ./containers/minecraft-server-test
    # ./containers/vintage-story
  ];

  nix.distributedBuilds = false; # TEMP: Test if the builder unfucks itself

  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  # TODO: remote access

  system.autoUpgrade.enable = true; # Hands-free updates

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };
  system.stateVersion = "22.11";
}
