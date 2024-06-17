{ config, pkgs, fop-utils, lib, ... }:
with lib;
let
  cursorTheme = "Breeze_Light";
in
{
  home.packages = with pkgs; [
    (papirus-icon-theme.override {
      color = "blue";
    })
    plasmadeck-vapor-theme # TODO: theme-specific
  ];

  home.pointerCursor = {
    package = pkgs.kdePackages.breeze;
    name = cursorTheme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.plasma = {
    workspace = {
      # https://sourcegraph.com/github.com/pjones/plasma-manager@trunk/-/blob/modules/workspace.nix
      theme = "Vapor";
      colorScheme = "Vapor";
      lookAndFeel = "com.valve.vapor.desktop";
      iconTheme = "Papirus-Dark";
      inherit cursorTheme;
    };

    configFile =
      let
        gtkSettings = {
          Settings = {
            gtk-theme-name = config.programs.plasma.workspace.theme;
            gtk-cursor-theme-name = config.programs.plasma.workspace.cursorTheme;
          };
        };
      in
      (fop-utils.mkOverrideRecursively 900 {
        "gtk-3.0/settings.ini" = gtkSettings;
        "gtk-4.0/settings.ini" = gtkSettings;

        # Lock screen
        # TODO: Check if it actually updates by plasma-manager
        kscreenlockerrc = {
          # Double-escaping is dumb but works
          "Greeter.Wallpaper.org\\.kde\\.image.General" =
            let
              image = "${pkgs.plasmadeck-vapor-theme}/share/wallpapers/Steam Deck Logo 5.jpg";
            in
            {
              Image = image;
              PreviewImage = image;
            };
        };

        # Breeze window decors
        kwinrc."org\\.kde\\.kdecoration2" = {
          # Default override to Breeze as Wayland is quite broken on others and Breeze just looks nice
          library = "org.kde.breeze";
          theme = "Breeze";
        };
        breezerc = {
          "Common" = {
            OutlineCloseButton = true;
            ShadowSize = "ShadowSmall";
          };
        };
      });
  };
}
