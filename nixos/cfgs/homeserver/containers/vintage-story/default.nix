{ config, ... }:
let
  CFTunnelID = "a54553c6-b83e-4ff8-933b-96d2cf92007b";
  externalPort = 42420; # Match with the module config! 
  # TODO: Maybe rework it better ^ 
in
{
  sops.secrets = {
    vintage-story-tunnel = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
      owner = config.services.cloudflared.user;
      group = config.services.cloudflared.group;
      restartUnits = [ "cloudflared-tunnel-${CFTunnelID}.service" ];
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      ${CFTunnelID} = {
        credentialsFile = config.sops.secrets.vintage-story-tunnel.path;
        default = "http_status:404";
        ingress = {
          "vs.faupi.net" = "tcp://localhost:${toString externalPort}";
        };
      };
    };
  };

  # Use the module handling
  my = {
    vintagestory = {
      server.enable = false;
      mods.enable = false; # TODO: CHANGE WHEN MODS READY LOOOL 
    };
  };
}
