{ config, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./boot.nix
    ./hardware.nix
  ];
  services.qemuGuest.enable = true;

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  my = {
    plasma = {
      enable = true;
    };
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "faupi";
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
          inotify-tools # For testing configs
          wineWowPackages.wayland
          yad
          winetricks
          wget
          cabextract
          unzip
          BROWSERS.firefox
        ];
      };
    };
  };

  # build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MB
      diskSize = 20000; # MB
      cores = 8;
    };
  };

  system.stateVersion = "23.11";
}
