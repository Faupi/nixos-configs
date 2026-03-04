{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.dank-material-shell;
in
{
  config = lib.mkIf cfg.enable {
    # Pre-start KDE portal to avoid DBus activation timeouts (improves DMS startup).
    systemd.user.targets.graphical-session.wants = [
      "plasma-xdg-desktop-portal-kde.service"
    ];
    # Avoid waiting on plasma-core in non-Plasma sessions.
    systemd.user.services.plasma-xdg-desktop-portal-kde.unitConfig = {
      After = [ "graphical-session.target" ];
    };
    systemd.user.services.xdg-desktop-portal.unitConfig = {
      After = [ "plasma-xdg-desktop-portal-kde.service" ];
      Wants = [ "plasma-xdg-desktop-portal-kde.service" ];
    };

    # Use KDE's shipped applications.menu for kbuildsycoca/Dolphin.
    # NOTE: qt5 because "the whole sycoca situation is very bad" (it's missing in qt6)
    environment.etc."xdg/menus/applications.menu".source =
      "${pkgs.libsForQt5.kservice}/etc/xdg/menus/applications.menu";
    # Rebuild KDE service database on session start so Dolphin "Open With" is populated.
    systemd.user.services.kbuildsycoca6 = {
      description = "Rebuild KDE service cache";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.kdePackages.kservice} --noincremental";
      };
    };
  };
}
