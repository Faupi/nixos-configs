{ config, pkgs, lib, ... }:
{
  # sops.secrets = {
  #   hamachi-creds = {
  #     sopsFile = ./secrets.yaml;
  #     mode = "0440";
  #   };
  # };

  services.logmein-hamachi.enable = true;

  systemd.services.hamachi-autologin = {
    enable = true;
    description = "Hamachi autologin connector";
    wantedBy = [ "logmein-hamachi.service" ];
    after = [ "logmein-hamachi.service" ];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.logmein-hamachi "hamachi"} login";
    };
  };

  # Use the module handling
  my = {
    vintagestory = {
      mods.enable = false; # TODO: CHANGE WHEN MODS READY LOOOL 
      server.enable = true;
    };
  };
}
