{ config, lib, ... }:
let
  cfg = config.flake-configs.syncDesktopItems;
in
{
  options.flake-configs.syncDesktopItems = {
    enable = lib.mkEnableOption "desktop item synchronization";
  };

  config = lib.mkIf cfg.enable {
    # Enable desktop item sync with KDE plasma
    targets.genericLinux.enable = true;
    xdg.mime.enable = true;
    xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
  };
}
