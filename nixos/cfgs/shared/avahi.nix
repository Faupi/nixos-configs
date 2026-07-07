{ config, lib, ... }:
let
  cfg = config.flake-configs.avahi;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.flake-configs.avahi = {
    enable = mkEnableOption "Enable config set for avahi";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
}
