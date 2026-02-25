{ lib, pkgs, cfg, ... }:
let
  inherit (lib) mkIf mkMerge;
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      systemd.user.services."org.gnome.GPaste" = {
        Unit = {
          Description = "GPaste daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.gpaste}/libexec/gpaste/gpaste-daemon";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      systemd.user.services."org.gnome.GPaste.Ui" = {
        Unit = {
          Description = "GPaste user interface";
        };
        Service = {
          ExecStart = "${pkgs.gpaste}/libexec/gpaste/gpaste-ui --gapplication-service";
        };
      };

      systemd.user.services."org.gnome.GPaste.Preferences" = {
        Unit = {
          Description = "GPaste preferences";
        };
        Service = {
          ExecStart = "${pkgs.gpaste}/libexec/gpaste/gpaste-preferences --gapplication-service";
        };
      };
    }
  ]);
}
