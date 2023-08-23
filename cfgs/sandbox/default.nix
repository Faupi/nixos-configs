{ config, pkgs, lib, ... }: 
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.hostName = "sandbox";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  my = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      user = "faupi";
    };
  };

  services.xserver.displayManager.defaultSession = "plasmawayland";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      faupi = {
        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          inotify-tools  # For testing configs
        ];
      };
    };
  };

  # build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;         
    };
  };

  system.stateVersion = "22.11";
}
