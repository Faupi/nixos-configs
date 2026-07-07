{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.ananicy;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flake-configs.ananicy = {
    enable = mkEnableOption "Enable config set for ananicy";
  };

  config = mkIf cfg.enable {
    services.ananicy = {
      enable = true;
      package = pkgs.unstable.ananicy-cpp;
      rulesProvider = pkgs.unstable.ananicy-rules-cachyos;
    };
  };
}
