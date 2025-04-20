{ config, pkgs, fop-utils, lib, cfg, ... }:
with lib;
let
  cursorTheme = "Breeze_Light";
  cursorSize = 24;

  # TODO: Add a theme package option?
  themePackage = pkgs.leaf-theme-kde;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      papirus-icon-theme # NOTE: Color overrides seem to be broken (take forever to build, and won't apply)
      themePackage
    ];

    home.pointerCursor = {
      package = pkgs.kdePackages.breeze;
      name = cursorTheme;
      size = cursorSize;
      gtk.enable = true;
      x11.enable = true;
    };

    programs.plasma = {
      workspace = {
        inherit (themePackage) colorScheme theme lookAndFeel;
        iconTheme = "Papirus-Dark";
        cursor = {
          theme = cursorTheme;
          size = cursorSize;
        };
      };
      kscreenlocker.appearance = {
        wallpaper = lib.mkDefault "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
        alwaysShowClock = true;
        showMediaControls = true;
      };

      # Set GTK themes
      configFile =
        let
          gtkSettings = {
            Settings = {
              gtk-theme-name = "Breeze"; # Leaf does not have a GTK theme implementation as of now (and default is Breeze light mode)
              gtk-cursor-theme-name = config.programs.plasma.workspace.cursor.theme;
            };
          };
        in
        (fop-utils.mkOverrideRecursively 900 {
          "gtk-3.0/settings.ini" = gtkSettings;
          "gtk-4.0/settings.ini" = gtkSettings;
        });
    };
  };
}
