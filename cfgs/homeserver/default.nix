{ config, pkgs, lib, ... }: {
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.hostName = "homeserver";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "22.11";
}
