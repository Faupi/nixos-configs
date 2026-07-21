{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  networking = {
    useDHCP = mkDefault true;
    networkmanager.enable = mkDefault true;
  };

  # Resolved DNS
  services.resolved.enable = mkDefault true;

  # Static names for adapters
  services.udev.extraRules = ''
    # 2.5G ethernet adapter on monitor
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="c0:ea:c3:67:b7:5b", NAME="eth-dock"
  '';
}
