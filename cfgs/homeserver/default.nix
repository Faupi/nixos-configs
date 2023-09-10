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

  # TODO: Do a proper nixremote user setup

  nix.settings.trusted-users = [
    "nixremote"  # Builder user
  ];

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
      nixpkgs.overlays = host-config.nixpkgs.overlays;

      networking.firewall = {
        enable = true;
        allowedUDPPorts = [ 14004 ];
        allowedTCPPorts = [ 14004 ];
      };

      environment.systemPackages = [
        pkgs.veloren-server-cli
      ];

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
