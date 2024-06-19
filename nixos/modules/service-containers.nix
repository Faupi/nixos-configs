{ lib, config, ... }:
with lib;
let
  cfg = config.portForwardedContainers;
in
{
  options.portForwardedContainers = mkOption {
    default = { };
    type = with types; attrsOf (submodule (
      { name, options, ... }: {
        options = {
          enable = mkEnableOption "Enable container";
          autoStart = mkEnableOption "Whether to start the container automatically upon activation";
          ports = {
            open = mkEnableOption "Open ports in firewall";
            tcp = mkOption {
              description = "Mapping of TCP ports host:container";
              default = { };
              example = { "20000" = 8080; };
              type = with types; attrsOf int;
            };
            udp = mkOption {
              description = "Mapping of UDP ports host:container";
              default = { };
              example = { "20000" = 8080; };
              type = with types; attrsOf int;
            };
          };
          config = mkOption {
            description = "Container configuration";
          };
        };
      }
    ));
  };

  config = {
    containers = (flip mapAttrs cfg (name: container: (mkIf container.enable {
      inherit (container) autoStart;
      privateNetwork = false;
      forwardPorts =
        (flip attrsets.mapAttrsToList container.ports.tcp (external: internal: {
          hostPort = toInt external;
          containerPort = internal;
          protocol = "tcp";
        }))
        ++
        (flip attrsets.mapAttrsToList container.ports.udp (external: internal: {
          hostPort = toInt external;
          containerPort = internal;
          protocol = "udp";
        }));
      extraFlags = [ "-U" ];

      config = { ... }: {
        imports = [ container.config ];

        # Open ports on container
        networking.firewall = {
          allowedTCPPorts = flip attrsets.mapAttrsToList container.ports.tcp (_: internal: internal);
          allowedUDPPorts = flip attrsets.mapAttrsToList container.ports.udp (_: internal: internal);
        };
      };
    })));

    # Open ports on host if applicable
    networking.firewall = mkMerge (flip mapAttrsToList cfg (
      name: container: (
        mkIf container.ports.open {
          allowedTCPPorts = flip attrsets.mapAttrsToList container.ports.tcp (external: _: toInt external);
          allowedUDPPorts = flip attrsets.mapAttrsToList container.ports.udp (external: _: toInt external);
        }
      )
    ));
  };
}
