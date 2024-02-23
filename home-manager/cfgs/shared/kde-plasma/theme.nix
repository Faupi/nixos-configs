{ config, pkgs, fop-utils, ... }: {
  home.packages = with pkgs; [
    papirus-icon-theme
    plasmadeck-vapor-theme # TODO: theme-specific
  ];

  programs.plasma = {
    workspace = {
      # https://sourcegraph.com/github.com/pjones/plasma-manager@trunk/-/blob/modules/workspace.nix
      theme = "Vapor";
      colorScheme = "Vapor";
      lookAndFeel = "com.valve.vapor.desktop";
      cursorTheme = "Breeze_Snow";
      iconTheme = "Papirus-Dark";
    };

    configFile =
      let
        gtkSettings = {
          Settings.gtk-theme-name = config.programs.plasma.workspace.theme;
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
