{ cfg, config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkForce;
in
{
  config = mkIf cfg.enable {
    # "Disable Built-in Wallpapers" under External Wallpaper Management
    programs.dank-material-shell.settings = {
      screenPreferences = {
        wallpaper = mkForce [ ];
      };
    };

    programs.mpvpaper = {
      enable = true;
      package = pkgs.mpvpaper;
    };

    systemd.user.services.mpvpaper = {
      Unit = {
        Description = "mpvpaper wallpaper";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = ''
          ${lib.getExe config.programs.mpvpaper.package} \
            --auto-pause \
            --layer background \
            -o "hwdec=vaapi no-audio loop panscan=1 scale=bilinear cache=yes demuxer-max-bytes=200MiB" \
            ALL \
            ${config.home.homeDirectory}/Pictures/Wallpapers/fox-video/h264.mp4
        '';
        Restart = "always";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
