{ ... }: {
  imports = [
    ./builder
    ./hardware.nix
    ./notify-email.nix

    ./containers/home-assistant
  ];

  nix.distributedBuilds = false;

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade = {
    enable = true;
    operation = "switch";
    allowReboot = true;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };
  system.stateVersion = "22.11";
}
