{ pkgs, homeUsers, system, lib, ... }:
let
  inherit (lib) mkForce;
in
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
    plymouth.enable = true;

    mango = {
      enable = true;
      displayManager = {
        enable = true;
        userConfigHome = "/home/masp";
      };
    };

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

    nix-ld = {
      enable = true;
      useLibraries = {
        deadZoneRevive = true;
      };
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

      programs.dank-material-shell = {
        plugins.amdGpuMonitorRevive.enable = mkForce false;
      };
    };
  };

  # FIXME: Workaround for DMS polkit selection issue https://github.com/AvengeMedia/DankMaterialShell/issues/3251
  security.polkit = {
    enable = true;
    adminIdentities = [ "unix-user:masp" ];
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
