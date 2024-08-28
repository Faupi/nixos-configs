{ config, pkgs, fop-utils, lib, ... }:
with lib;
let
  cursorTheme = "Breeze_Light";
  cursorSize = 24;
in
{
  home.packages = with pkgs; [
    (papirus-icon-theme.override { color = "green"; })
    leaf-theme.kde # TODO: theme-specific
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
      # https://sourcegraph.com/github.com/pjones/plasma-manager@trunk/-/blob/modules/workspace.nix
      theme = "Leaf";
      colorScheme = "LeafDark";
      lookAndFeel = "leaf-dark";
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
            gtk-theme-name = "breeze-dark"; # Leaf does not have a GTK theme implementation as of now (and default is breeze-light)
            gtk-cursor-theme-name = config.programs.plasma.workspace.cursor.theme;
          };
        };
      in
      (fop-utils.mkOverrideRecursively 900 {
        "gtk-3.0/settings.ini" = gtkSettings;
        "gtk-4.0/settings.ini" = gtkSettings;
      });
  };
}
