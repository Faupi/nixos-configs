{ config, pkgs, lib, ... }: 
let 
  host-config = config;
in
{
  # Veloren server
  networking.firewall = {
    # Open ports for forwarding to container
    allowedUDPPorts = [ 14004 ];
    allowedTCPPorts = [ 14004 ];
  };
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
}