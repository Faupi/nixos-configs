{ cfg, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flake-configs.mango = {
    displayManager = {
      enable = mkEnableOption "DMS greeter displayManager config";
      userConfigHome = lib.mkOption {
        type = lib.types.path;
        default = "/home/faupi"; # TODO: Main user
      };
    };
  };

  config = mkIf (cfg.enable && cfg.displayManager.enable) {
    programs.sway.enable = true;

    services.displayManager = {
      enable = true;
      defaultSession = "mango-uwsm";

      # Renamed to dux-greeter for 26.11
      dms-greeter = {
        enable = true;
        # Leave package and quickshell default - does not play well with dms flake!
        compositor.name = "sway"; # Switch to mangowc
        configHome = cfg.displayManager.userConfigHome;
      };
    };
  };
}
