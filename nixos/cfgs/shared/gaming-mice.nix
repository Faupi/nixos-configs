{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.gaming-mice;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flake-configs.gaming-mice = {
    enable = mkEnableOption "Enable config set for gaming mouse configuration";
  };

  config = mkIf cfg.enable {
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [
      piper
    ];
  };
}
