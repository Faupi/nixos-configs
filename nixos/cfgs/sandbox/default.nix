{ pkgs, modulesPath, ... }:
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
    gnome.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "test";
  };
  services.displayManager.defaultSession = "gnome";

  home-manager.users = {
    test = {
      imports = [
        (import ../../../home-manager/cfgs/shared/gnome)
      ];
      flake-configs = {
        gnome.enable = true;
      };
      home.packages = with pkgs; [
        inotify-tools # For testing configs
        wineWowPackages.wayland
        yad
        winetricks
        wget
        cabextract
        unzip
        xorg.xprop
      ];

      home = {
        username = "test";
        homeDirectory = "/home/test";
        stateVersion = "23.11";
      };
    };
  };
  users.users.test = {
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
