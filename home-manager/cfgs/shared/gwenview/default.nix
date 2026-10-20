{ config, lib, pkgs, fop-utils, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.gwenview;
in
{
  options.flake-configs.gwenview = {
    enable = mkEnableOption "Gwenview";
    setAsDefault = mkEnableOption "Set as default viewer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.kdePackages.gwenview ];
    xdg.mimeApps = mkIf cfg.setAsDefault {
      enable = true;
      defaultApplications = fop-utils.mimeDefaultsFor "org.kde.gwenview.desktop" [
        "image/avif"
        "image/gif"
        "image/heif"
        "image/jpeg"
        "image/jxl"
        "image/png"
        "image/bmp"
        "image/tiff"
        "image/webp"
        "image/x-webp"
        "image/svg+xml"
        "image/svg+xml-compressed"
        "image/x-ico"
        "image/x-icns"
        "image/x-eps"
        "image/x-tga"
        "image/x-psd"
        "image/x-xcf"
        "image/openraster"
        "image/x-portable-bitmap"
        "image/x-portable-graymap"
        "image/x-portable-pixmap"
        "image/x-xbitmap"
        "image/x-xpixmap"
      ];
    };
  };
}
