{ config, pkgs, lib, ... }:
{
  # Hamachi
  services.logmein-hamachi.enable = true;
  systemd.services.hamachi-autologin = {
    enable = true;
    description = "Hamachi autologin connector";
    wantedBy = [ "logmein-hamachi.service" ];
    after = [ "logmein-hamachi.service" ];
    serviceConfig = {
      ExecStart = "/run/wrappers/bin/sudo ${lib.getExe' pkgs.logmein-hamachi "hamachi"} login";
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
