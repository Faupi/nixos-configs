{ pkgs, modulesPath, homeUsers, ... }:
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

  services.displayManager.autoLogin = {
    enable = true;
    user = "faupi";
  };
  services.displayManager.defaultSession = "plasmawayland";

  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; }) ];
      home.packages = with pkgs; [
        inotify-tools # For testing configs
        wineWowPackages.wayland
        yad
        winetricks
        wget
        cabextract
        unzip
      ];
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
