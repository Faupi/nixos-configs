{ config, pkgs, lib, ... }: 
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  # TODO: Do a proper nixremote user setup
  nix.settings.trusted-users = [
    "nixremote"  # Builder user
  ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };

  system.stateVersion = "22.11";
}
