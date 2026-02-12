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

  flake-configs = {
    plasma6.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "masp";
  };
  services.displayManager.defaultSession = "plasma";

  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; }) ];
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
  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    password = "test";
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
