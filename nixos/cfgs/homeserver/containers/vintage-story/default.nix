{ config, pkgs, lib, ... }:
{
  sops.secrets = {
    hamachi-creds = {
      sopsFile = ./secrets.yaml;
      mode = "0440";
    };
  };

  # Use the module handling
  my = {
    vintagestory = {
      mods.enable = false; # TODO: CHANGE WHEN MODS READY LOOOL 
      server = {
        enable = true;
        extraConfig = {
          nixpkgs.config.allowUnfree = true;

          services.logmein-hamachi.enable = true;

          systemd.services.vintagestory-server.serviceConfig.ExecStart = "${lib.getExe pkgs.logmein-hamachi} login & ";
        };
      };
    };
  };
}
