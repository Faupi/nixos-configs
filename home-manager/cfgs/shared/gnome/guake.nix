{ lib, pkgs, cfg, ... }:
let
  inherit (lib) mkIf mkMerge;
  autostartGuake = pkgs.makeAutostartItem rec {
    name = "guake";
    package = pkgs.makeDesktopItem {
      inherit name;
      desktopName = "Guake";
      exec = "guake";
      extraConfig = {
        OnlyShowIn = "GNOME";
      };
    };
  };
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        guake
        autostartGuake
      ];
    }
  ]);
}
