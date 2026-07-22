{ cfg, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flake-configs.dank-material-shell = {
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
      dms-greeter = {
        enable = true;
        compositor.name = "sway";
        configHome = cfg.displayManager.userConfigHome;
      };
    };
  };
}
