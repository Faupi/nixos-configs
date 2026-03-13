# TODO: Figure out what to do with the files

{ cfg, config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkForce;
in
{
  config = mkIf cfg.enable {
    programs.dank-material-shell.settings = {
      # "Disable Built-in Wallpapers" under External Wallpaper Management
      screenPreferences = {
        wallpaper = mkForce [ ];
      };

      # Set a wallpaper fallback (primarily for lockscreen/previews)
      wallpaperPath = "${config.home.homeDirectory}/Pictures/Wallpapers/fox-video/fallback.png";
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
        ConditionEnvironment = [
          "XDG_CURRENT_DESKTOP=niri"
        ];
      };

      Service = {
        ExecStart = ''
          ${lib.getExe config.programs.mpvpaper.package} \
            --auto-pause \
            --layer background \
            -o "hwdec=vaapi quiet no-audio loop panscan=1 scale=bilinear cache=yes demuxer-max-bytes=200MiB" \
            ALL \
            ${config.home.homeDirectory}/Pictures/Wallpapers/fox-video/h264.mp4
        '';
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
