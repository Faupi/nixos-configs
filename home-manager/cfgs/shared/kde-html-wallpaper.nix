{ pkgs, ... }:
let
  package = pkgs.kde-html-wallpaper;
in
{
  home.file."Plasma wallpaper - HTML wallpaper type" = {
    source = package;
    target = ".local/share/plasma/wallpapers/${package.pluginName}/";
    recursive = true;
  };

  # TODO: For auto-enabling, file:///home/faupi/.config/plasma-org.kde.plasma.desktop-appletsrc needs a module
}
