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
      openFirewall = true;
      nssmdns4 = true;
      nssmdns6 = true;

      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };

    # Avoid conflict with systemd-resolved
    # https://wiki.archlinux.org/title/Systemd-resolved#mDNS
    services.resolved.settings.Resolve.MulticastDNS = "resolve";
  };
}
