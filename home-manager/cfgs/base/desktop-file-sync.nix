# Update local user desktop file database on login. 
# Makes sure locally-added desktop files get picked up for e.g. URI handlers, specifically gio, which is often used in browsers to launch external apps.

{ pkgs, lib, ... }: {
  systemd.user.services.update-desktop-database = {
    Unit = {
      Description = "Update user desktop application database";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.desktop-file-utils "update-desktop-database"} %h/.local/share/applications";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
