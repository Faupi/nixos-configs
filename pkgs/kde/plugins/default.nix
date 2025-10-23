{ pkgs, ... }: {
  adaptive-window-opacity = pkgs.callPackage ./adaptive-window-opacity { };
  html-wallpaper = pkgs.callPackage ./html-wallpaper { };
}
