{ config, pkgs, lib, ... }:
with lib;
{
  config = mkMerge [
    {
      home.packages = with pkgs; [
        corepack
      ];
    }

    (mkIf config.graphical {
      home.packages = with pkgs; [
        (config.lib.nixgl.wrapPackage krita)
        (config.lib.nixgl.wrapPackage epiphany)
        (config.lib.nixgl.wrapPackage moonlight-qt)
      ];

      programs = {
        # 1Password is taken from system package manager

        firefox.profiles.masp.isDefault = true;
      };
    })
  ];
}
