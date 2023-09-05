{ config, pkgs, lib, ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.hostName = "homeserver";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  # TODO: Do a proper nixremote user setup

  nix.settings.trusted-users = [
    "nixremote"  # Builder user
  ];

  system.stateVersion = "22.11";
}
