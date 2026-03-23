# https://github.com/jervw/snowflake/blob/8d83d3a8a11ba5a4f62e33554316532417ca2212/modules/nixos/programs/addons/ntsync/default.nix

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  cfg = config.boot.ntsync;
in
{
  options.boot.ntsync = {
    enable = lib.mkEnableOption "Enable ntsync support";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "ntsync" ];

    # make ntsync device accessible
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];

    assertions = [
      {
        assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
        message = "Option `boot.ntsync.enable` requires Linux 6.14+.";
      }
    ];
  };
}
