{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.dank-material-shell;
in
{
  config = lib.mkIf cfg.enable {
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
