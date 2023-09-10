{ config, pkgs, lib, ... }: 
let 
  host-config = config;
in
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.hostName = "homeserver";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  nix = {
    settings = {
      # TODO: Do a proper nixremote user setup
      trusted-users = [
        "nixremote"  # Builder user
      ];

      # Veloren Cachix
      substituters = [
        "https://cache.nixos.org/"
        "https://veloren-nix.cachix.org"
      ];
      trusted-public-keys = [
        "veloren-nix.cachix.org-1:zokfKJqVsNV6kI/oJdLF6TYBdNPYGSb+diMVQPn/5Rc="
      ];
    };
  };

  # Veloren server
  containers.veloren = {
    autoStart = true;
    privateNetwork = false;
    forwardPorts = [
      {
        containerPort = 14004;
        hostPort = 14004;
        protocol = "tcp";
      }
      {
        containerPort = 14004;
        hostPort = 14004;
        protocol = "udp";
      }
    ];

    config = 
    { config, pkgs, ... }: {
      # Inherit overlays
      nixpkgs.overlays = host-config.nixpkgs.overlays;

      networking.firewall = {
        enable = true;
        allowedUDPPorts = [ 14004 ];
        allowedTCPPorts = [ 14004 ];
      };

      systemd.services.veloren-server = {
        enable = true;
        description = "Veloren server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Restart = "always";
          ExecStart = "${pkgs.veloren-server-cli}/bin/veloren-server-cli";
        };
      };

      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.05";
    };
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };

  system.stateVersion = "22.11";
}
