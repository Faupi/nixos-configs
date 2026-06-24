{ config, cfg, ... }: {
  users.groups.playit = { };

  sops.secrets = {
    playit-token = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
      owner = cfg.user;
      group = "playit";
      restartUnits = [ "playit.service" ];
    };
  };

  services.playit = {
    enable = true;
    secretPath = config.sops.secrets.playit-token.path;
  };
}
