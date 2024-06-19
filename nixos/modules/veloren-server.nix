{ config, lib, ... }:
let
  host-config = config;
in
{
  nix.settings = {
    substituters = [
      "https://veloren-nix.cachix.org"
    ];
    trusted-public-keys = [
      "veloren-nix.cachix.org-1:zokfKJqVsNV6kI/oJdLF6TYBdNPYGSb+diMVQPn/5Rc="
    ];
  };

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
    extraFlags = [ "-U" ];

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
            ExecStart = lib.getExe pkgs.veloren-server-cli;
          };
        };

        environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

        system.stateVersion = "23.05";
      };
  };
}
