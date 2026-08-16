{ config, ... }: {
  sops.secrets = {
    playit-token = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
      owner = "faupi";
      group = "users";
      restartUnits = [ "playit.service" ];
    };
  };

  services.playit = {
    enable = true;
    secretPath = config.sops.secrets.playit-token.path;
  };
}
