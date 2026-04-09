{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  # DHCP
  networking.useDHCP = mkDefault true;

  # Resolved DNS
  services.resolved.enable = mkDefault true;
}
