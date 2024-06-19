{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.my.localsend;
in
{
  options.my.localsend = {
    enable = mkEnableOption "Enable LocalSend";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ pkgs.localsend ];

      networking.firewall = {
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };
    })
  ];
}
