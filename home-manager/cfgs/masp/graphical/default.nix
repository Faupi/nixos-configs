{ config, pkgs, lib, ... }:
with lib;
{
  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    moonlight-qt

    epiphany
    chromium
    postman

    libreoffice-qt-fresh # TODO: Add config for icon theme (default has dark icons on dark background)

    bottles
    remmina
  ];

  programs = {
    firefox.profiles.masp.isDefault = true;
    plasma.workspace.wallpaper = builtins.fetchurl {
      url = "https://faupi.net/wallpaper-2.jpg";
      sha256 = "0fai4gpfxdhr0kbjnwr3k251x6ks4zi7fn9z7k6an31sb6r92y1x";
    };
  };
}
