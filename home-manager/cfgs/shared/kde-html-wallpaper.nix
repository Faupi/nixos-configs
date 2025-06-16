{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libsForQt5.qt5.qtwebengine
    kde.html-wallpaper
  ];
}
