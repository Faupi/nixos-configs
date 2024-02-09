{ config, pkgs, homeUsers, ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

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
        imports = [ homeUsers.faupi ];

        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          inotify-tools # For testing configs
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

  system.stateVersion = "23.11";
}
