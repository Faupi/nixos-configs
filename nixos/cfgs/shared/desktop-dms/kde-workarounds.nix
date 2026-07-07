{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.dank-material-shell;
in
{
  config = lib.mkIf cfg.enable {
    # kbuildsycoca6 expects applications.menu outside of a Plasma session.
    # Plasma only ships plasma-applications.menu, so expose it under the
    # generic name to make Dolphin's "Open With" dialog populate correctly.
    environment.etc."xdg/menus/applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

    # Rebuild KDE service database on session start so Dolphin "Open With" is populated.
    systemd.user.services.kbuildsycoca6 = {
      description = "Rebuild KDE service cache";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental";
      };
    };
  };
}
