{ cfg, lib, pkgs, ... }:
let
  inherit (lib) mkIf getExe';
in
{
  config = mkIf cfg.enable {
    # Provide Plasma's XDG menu definition
    environment.etc."xdg/menus/plasma-applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

    # Use the correct one in mango
    environment.etc."xdg/uwsm/env-mango".text = ''
      export XDG_MENU_PREFIX=plasma-
    '';

    # Rebuild KDE service database on session start.
    systemd.user.services.kbuildsycoca6 = {
      description = "Rebuild KDE service cache";
      wantedBy = [ "graphical-session.target" ];
      after = [
        "graphical-session.target"
        "update-desktop-database.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental";
      };
    };
  };
}
