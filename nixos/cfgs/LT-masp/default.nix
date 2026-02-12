{ pkgs, homeUsers, ... }:
{
  imports = [
    ./auth.nix
    ./hardware.nix
    # ./management.nix # Who knows when this will be needed
  ];

  services.resolved.enable = true; # Use systemd-resolved for DNS - needed for OpenVPN despite the setting (roll eyes)
  networking = {
    networkmanager.enable = true;
    firewall = {
      interfaces.enp3s0 = {
        allowedUDPPorts = [ 53 67 ]; # For subnet DHCP
      };
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  flake-configs = {
    plasma6.enable = true;
    plymouth.enable = true;

    audio = {
      enable = true;
      user = "masp";
    };

    _1password = {
      enable = true;
      users = [ "masp" ];
      autoStart = true;
      useSSHAgent = true;
    };

    monitor-input-switcher = {
      enable = false;
      user = "masp";
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
    openvpn3 = {
      enable = true;
      netcfg.settings.systemd_resolved = true;
      indicator = {
        enable = true;
        autoStart = true;
      };
    };
    kdeconnect.enable = true;
    adb.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];

  system.stateVersion = "23.11";
}
