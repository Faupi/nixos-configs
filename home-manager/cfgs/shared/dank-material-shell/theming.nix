{ lib, cfg, pkgs, config, ... }:
let
  inherit (lib) mkIf recursiveUpdate;

  cursor = {
    package = pkgs.kdePackages.breeze;
    name = "Breeze_Light";
    size = 24; # For wayland
  };

  icon-theme = (pkgs.flat-remix-icon-theme.overrideAttrs (old: rec {
    version = "20251119";
    src = pkgs.fetchFromGitHub {
      owner = "daniruiz";
      repo = "flat-remix";
      rev = version;
      sha256 = "sha256-tQCzxMz/1dCsPSZHJ9bIWCRjPi0sS7VhRxttzzA7Tr4=";
    };
  }));
  icon-theme-name = "Flat-Remix-Orange-Dark";

  preset-orchis-theme = pkgs.orchis-theme.override {
    border-radius = 8;
    tweaks = [
      "black" # Full black
      "primary" # Primary color in checkboxes etc
      "submenu" # Somehow makes submenus contrast more
      "solid" # Full transparency
    ];
  };
in
{
  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      colorScheme = "dark";
      theme = {
        name = "Orchis-Orange-Dark";
        package = preset-orchis-theme;
      };
      iconTheme = {
        name = icon-theme-name;
        package = icon-theme;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4 = {
        theme = config.gtk.theme;
        extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
    };
    # Make GNOME-native apps happy too (e.g. screenshare portals)
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = config.gtk.theme.name;
          icon-theme = config.gtk.iconTheme.name;
          cursor-theme = cursor.name;
          accent-color = "orange";
          font-antialiasing = "rgba";
          font-hinting = "slight";
          text-scaling-factor = 1.0;
        };
      };
    };

    qt = rec {
      enable = true;
      # style.name = config.gtk.theme.name; # qtct should be taking care of this
      platformTheme.name = "qtct";
      qt6ctSettings = {
        Appearance = {
          style = "Breeze-Dark";
          icon_theme = config.gtk.iconTheme.name;
          color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf";
          custom_palette = true;
          standard_dialogs = "xdgdesktopportal";
        };

        Fonts = {
          # Push thin weight, as "Regular" is even lighter than Thin, making it impossible to read.
          # NOTE: Only some apps really resolve weight on their own and pick the right one, so this is pretty necessary.
          # NOTE: Double quotation is required.
          general = "\"Outfit,12,-1,5,25,0,0,0,0,0\"";
        };
      };
      qt5ctSettings = recursiveUpdate qt6ctSettings {
        Appearance.color_scheme_path = "${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf";
      };

      # Make the rest of KDE apps happy
      kde.settings = rec {
        kdeglobals = {
          General.ColorScheme = "DankMatugenDark";
          UiSettings.ColorScheme = kdeglobals.General.ColorScheme;
          Icons.Theme = config.gtk.iconTheme.name;
        };
        dolphinrc = {
          UiSettings.ColorScheme = kdeglobals.General.ColorScheme;
        };
        konsolerc = {
          UiSettings.ColorScheme = kdeglobals.General.ColorScheme;
        };
        "haruna/haruna.conf" = {
          General = {
            ColorScheme = "Dank Shell (matugen)";
            GuiStyle = "qt6ct-style";
          };
        };
      };
    };

    home.pointerCursor = {
      package = cursor.package;
      name = cursor.name;
      size = cursor.size;
      gtk.enable = true;
      x11.enable = true;
    };

    # Make sure the packages are generally available
    home.packages = with pkgs; [
      # Themes
      icon-theme
      preset-orchis-theme

      # Themes - KDE
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.breeze
      kdePackages.breeze.qt5
    ];
  };
}
