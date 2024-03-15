{ config, ... }:
let
  defaultSecretConf = {
    sopsFile = ./secrets.json;
    mode = "0440";
    owner = config.services.cloudflared.user;
    group = config.services.cloudflared.group;
  };

  minecraftTunnelID = "5754289b-6e5a-4b40-845d-4c0386deaf15";
in
{
  sops.secrets = {
    minecraft-tunnel = defaultSecretConf // { restartUnits = [ "cloudflared-tunnel-${minecraftTunnelID}.service" ]; };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      ${minecraftTunnelID} = {
        credentialsFile = config.sops.secrets.minecraft-tunnel.path;
        default = "http_status:404";
        ingress = {
          "mc.faupi.net" = {
            service = "tcp://localhost:25565";
          };
        };
      };
    };
  };
}
