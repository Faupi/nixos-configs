{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.unityhub;
in
{
  options.flake-configs.unityhub.enable =
    lib.mkEnableOption "Unity Hub";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unityhub ];
    xdg.mimeApps = {
      enable = lib.mkDefault true;
      defaultApplications = {
        "x-scheme-handler/unityhub" = "unityhub.desktop";
      };
    };
  };
}
