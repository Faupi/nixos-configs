{ inputs, config, lib, pkgs, ... }@args:
let
  inherit (lib) mkEnableOption mkIf recursiveUpdate;
  inherit (builtins) fromJSON unsafeDiscardStringContext readFile;

  cfg = config.flake-configs.dank-material-shell;

  cursor = {
    package = pkgs.kdePackages.breeze;
    name = "Breeze_Light";
    size = 24; # For wayland
  };

  dmsTheme = import ./theme.nix args;

  flat-remix-icons = (pkgs.flat-remix-icon-theme.overrideAttrs (old: rec {
    version = "20251119";
    src = pkgs.fetchFromGitHub {
      owner = "daniruiz";
      repo = "flat-remix";
      rev = version;
      sha256 = "sha256-tQCzxMz/1dCsPSZHJ9bIWCRjPi0sS7VhRxttzzA7Tr4=";
    };
  }));

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
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dms-plugin-registry.modules.default
  ]
  ++ (map (mod: (import mod (args // { inherit cfg; }))) [
    ./niri
  ]);

  options.flake-configs.dank-material-shell = {
    enable = mkEnableOption "Dank Material Shell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      flat-remix-icons
      preset-orchis-theme

      # KDE
      libsForQt5.qt5ct
      kdePackages.qt6ct
      kdePackages.breeze
      kdePackages.breeze.qt5
    ];

    gtk = {
      enable = true;
      colorScheme = "dark";
      theme = {
        name = "Orchis-Orange-Dark";
        package = preset-orchis-theme;
      };
      iconTheme = {
        name = "Flat-Remix-Orange-Dark";
        package = flat-remix-icons;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
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
      platformTheme.name = "qt6ct";
      qt6ctSettings = {
        Appearance = {
          style = "Breeze-Dark";
          icon_theme = config.gtk.iconTheme.name;
          color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf";
          custom_palette = true;
          standard_dialogs = "xdgdesktopportal";
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
      };
    };

    home.pointerCursor = {
      package = cursor.package;
      name = cursor.name;
      size = cursor.size;
      gtk.enable = true;
      x11.enable = true;
    };
    home.sessionVariables = {
      NIXOS_OZONE_WL = 1;
    };

    xdg = {
      enable = true;
      autostart.enable = true;
      userDirs.createDirectories = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "org.kde.dolphin.desktop";
        };
      };
    };

    programs.dank-material-shell = {
      enable = true;

      settings = recursiveUpdate
        (fromJSON (unsafeDiscardStringContext (readFile ./settings.json)))
        {
          # Remap the theme, likely on export it'll point to the registry
          currentThemeCategory = "custom";
          currentThemeName = "custom";
          customThemeFile = pkgs.writeText "theme.json" (builtins.toJSON dmsTheme);
        };

      session = recursiveUpdate
        (fromJSON (unsafeDiscardStringContext (readFile ./session.json)))
        {
          isLightMode = false;
        };

      clipboardSettings = {
        maxHistory = 25;
        maxEntrySize = 50 * 1024 * 1024; # MB
        autoClearDays = 1;
        clearAtStartup = true;
        disabled = false;
        disableHistory = false;
        disablePersist = true;
      };

      niri = {
        enableSpawn = false; # Handled with systemd
        enableKeybinds = false;

        includes = {
          enable = true; # Enable config includes hack. Enabled by default.

          override = true; # If disabled, DMS settings won't be prioritized over settings defined using niri-flake
          originalFileName = "hm"; # A new name (without extension) for the config file generated by niri-flake.
          filesToInclude = [
            # Files under `$XDG_CONFIG_HOME/niri/dms` to be included into the new config
            "alttab" # Please note that niri will throw an error if any of these files are missing.
            "binds"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "windowrules"
            "wpblur"
          ];
        };
      };

      plugins = {
        calculator.enable = true;
        dankBatteryAlerts.enable = true;
        dankKDEConnect.enable = true;
        emojiLauncher.enable = true;
        niriWindows.enable = true;
      };
    };
  };
}
