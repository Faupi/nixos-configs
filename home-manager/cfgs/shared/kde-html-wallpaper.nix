{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5.qtwebengine
    kde-html-wallpaper
  ];

  # TODO: For auto-enabling, file:///home/faupi/.config/plasma-org.kde.plasma.desktop-appletsrc needs a module
}
