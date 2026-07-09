{ pkgs, homeUsers, system, ... }:
{
  imports = [
    ./hardware.nix
    # ./management.nix # Who knows when this will be needed
    ./uplink.nix
    ./virtualization.nix
  ];

  flake-configs = {
    ananicy.enable = true;
    avahi.enable = true;
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  services.resolved.enable = true; # Use systemd-resolved for DNS - needed for OpenVPN despite the setting (roll eyes)
  networking = {
    networkmanager.enable = true;
    firewall = {
      interfaces.enp3s0 = {
        allowedUDPPorts = [ 53 67 ]; # For subnet DHCP
      };
    };
  };

  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "nm-openvpn" "adbusers" ];
  };
  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; inherit system; }) ];
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
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  environment.unixODBCDrivers = with pkgs.unixodbcDrivers; [ msodbcsql18 ];

  system.stateVersion = "23.11";
}
