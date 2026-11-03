# Touchpad gesture utility

{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.touchegg;
in
{
  options.flake-configs.touchegg = {
    enable = mkEnableOption "Touchégg";
  };

  config = mkIf cfg.enable {
    home.file.".config/touchegg/touchegg.conf".source = ./config.xml;
  };
}
