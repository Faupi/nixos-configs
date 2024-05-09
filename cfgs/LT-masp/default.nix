{ pkgs, homeUsers, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    # ./management.nix # Who knows when this will be needed
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

  services.displayManager = {
    defaultSession = "plasmawayland";
    sddm.enable = true;
  };

  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "nm-openvpn" "adbusers" ];
  };
  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; }) ];
    };
  };

  networking.firewall =
    # LocalSend
    {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };

  programs.kdeconnect.enable = true;

  programs.adb.enable = true;

  system.stateVersion = "23.11";
}
