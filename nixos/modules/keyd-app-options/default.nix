{ config, lib, pkgs, ... }:
let
  cfg = config.services.keyd;
in
{
  options.services.keyd.apps = lib.mkOption {
    type = (pkgs.formats.ini { }).type;
    default = { };
    example = {
      zen = {
        mouse1 = "kpplus";
        mouse2 = "kpminus";
      };
    };
    description = ''
      Application-specific keyd mappings written to {file}`/etc/keyd/app.conf`.
      Each attribute is an INI section named after the application.
    '';
  };

  options.services.keyd.applicationMapper = {
    enable = lib.mkEnableOption "the keyd application mapper user service";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "faupi" ];
      description = "Users that may run the keyd application mapper.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.etc."keyd/app.conf".text = lib.generators.toINI { } cfg.apps;
    }
    (lib.mkIf cfg.applicationMapper.enable {
      users.groups.keyd = { };
      users.users = lib.genAttrs cfg.applicationMapper.users (_: {
        extraGroups = [ "keyd" ];
      });

      systemd.services.keyd.serviceConfig.CapabilityBoundingSet = [
        "CAP_SETGID"
      ];

      systemd.user.services.keyd-application-mapper = {
        description = "keyd application mapper";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        path = [ cfg.package ];
        serviceConfig = {
          ExecStart = lib.getExe' cfg.package "keyd-application-mapper";
          Restart = "on-failure";
          RestartSec = 3;
        };
      };
    })
  ]);
}
