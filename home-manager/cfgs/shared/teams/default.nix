# REVIEW: Teams-for-linux might initially need `kdePackages.qtbase` available for `qtpaths` call - otherwise it takes like a minute to launch

{ config, pkgs, lib, fop-utils, ... }:
with lib;
let
  cfg = config.flake-configs.teams;

  wrapped-teams = fop-utils.enableWayland {
    inherit pkgs;
    package = config.lib.nixgl.wrapPackage (
      fop-utils.wrapPkgBinary {
        inherit pkgs;
        package = pkgs.teams-for-linux;
        nameAffix = "xdg";
        arguments = [
          "--appIcon '${./icon/teams-light.png}'"
          "--disableAutogain"
        ];
      }
    );
  };
in
{
  options.flake-configs.teams = {
    enable = mkEnableOption "Enable Teams for Linux";
    autoStart = {
      enable = mkEnableOption "Teams autostart";
      minimized = mkEnableOption "Start minimized";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      wrapped-teams
    ]
    ++ lists.optional cfg.autoStart.enable (pkgs.makeAutostartItem rec {
      name = "teams-for-linux";
      package = pkgs.makeDesktopItem {
        inherit name;
        desktopName = "Microsoft Teams for Linux";
        exec = (getExe wrapped-teams) + strings.optionalString cfg.autoStart.minimized " --minimized";
        icon = "teams-for-linux";
      };
    });

    apparmor.profiles.teams-for-linux.target = getExe wrapped-teams;
  };
}
