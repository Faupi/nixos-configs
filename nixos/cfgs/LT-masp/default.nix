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

  # TODO: Propagate across every device EXCEPT for the same builder - probably needs to be in flake.nix
  nix.settings.substituters = [
    "ssh-ng://nixremote@homeserver.local"
  ];

  my = {
    plasma6.enable = true;
    localsend.enable = true;

    _1password = {
      enable = true;
      users = [ "masp" ];
      autostart.enable = true;
      useSSHAgent = true;
    };
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

  programs = {
    openvpn3.enable = true;
    kdeconnect.enable = true;
    adb.enable = true;
  };
  environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];

  system.stateVersion = "23.11";
}
