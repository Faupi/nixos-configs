{ pkgs, homeUsers, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./management.nix
  ];

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  my = {
    plasma.enable = true;

    _1password = {
      enable = true;
      users = [ "masp" ];
      autostart.enable = true;
      useSSHAgent = true;
    };
  };

  services.xserver.displayManager = {
    defaultSession = "plasmawayland";
    sddm.enable = true;
  };

  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "nm-openvpn" ];
  };
  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; }) ];
    };
  };

  programs.kdeconnect.enable = true;

  system.stateVersion = "23.11";
}
