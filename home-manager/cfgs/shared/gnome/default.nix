args@{ config, lib, pkgs, ... }:
let
  inherit (lib) hm mkEnableOption mkIf mkMerge mkForce;

  cfg = config.flake-configs.gnome;
  wallpaperSrc = ../kde-plasma/theme/wallpaper.svg;
  wallpaperRelPath = "backgrounds/plasma-wallpaper.svg";
  wallpaperUri = "file://${config.xdg.dataHome}/${wallpaperRelPath}";

  cursor = {
    package = pkgs.kdePackages.breeze;
    name = "Breeze_Light";
    size = 24; # For wayland
  };

  flat-remix = {
    gtk = pkgs.flat-remix-gtk;
    gnome = pkgs.flat-remix-gnome;
    icons = (pkgs.flat-remix-icon-theme.overrideAttrs (old: rec {
      version = "20251119";
      src = pkgs.fetchFromGitHub {
        owner = "daniruiz";
        repo = "flat-remix";
        rev = version;
        sha256 = "sha256-tQCzxMz/1dCsPSZHJ9bIWCRjPi0sS7VhRxttzzA7Tr4=";
      };
    }));
  };
in
{
  options.flake-configs.gnome = {
    enable = mkEnableOption "Enable custom GNOME configuration";
  };

  imports = map (mod: (import mod (args // { inherit cfg; }))) [
    ./extensions
    ./guake.nix
  ];

  config = (mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        flat-remix-gtk
        flat-remix-gnome
        materia-theme
      ];

      xdg.dataFile.${wallpaperRelPath}.source = wallpaperSrc;

      gtk = {
        enable = true;
        theme = {
          name = "Materia-dark";
          package = pkgs.materia-theme;
        };
        iconTheme = {
          name = "Flat-Remix-Orange-Dark";
          package = flat-remix.icons;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      home.pointerCursor = {
        package = cursor.package;
        name = cursor.name;
        size = cursor.size;
        gtk.enable = true;
        x11.enable = true;
      };
      # Apply 200% scaling for X11 cursor
      home.sessionVariables = {
        XCURSOR_SIZE = mkForce (cursor.size * 2);
      };
      xresources.properties = {
        "Xcursor.size" = mkForce (cursor.size * 2);
      };

      dconf = {
        enable = true;
        settings = {
          # Keep GNOME overview on Super
          "org/gnome/mutter" = {
            overlay-key = "Super_L";
          };

          # Wallpapers
          "org/gnome/desktop/background" = {
            picture-uri = wallpaperUri;
            picture-uri-dark = wallpaperUri;
          };
          "org/gnome/desktop/screensaver" = {
            picture-uri = wallpaperUri;
          };

          # Dark theme
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "Materia-dark";
            icon-theme = "Flat-Remix-Orange-Dark";
            cursor-theme = cursor.name;
            accent-color = "orange";
            font-antialiasing = "rgba";
            font-hinting = "slight";
            text-scaling-factor = 1.0;
          };

          # Window manager theme for server-side decorations (XWayland)
          "org/gnome/desktop/wm/preferences" = {
            theme = "Materia-dark";
          };

          # GNOME Shell theme for server-side titlebars
          "org/gnome/shell/extensions/user-theme" = {
            name = "Flat-Remix-Darkest-fullPanel";
          };

          # File manager
          "org/gnome/nautilus/preferences" = {
            click-policy = "double"; # Single-click selects files, double-click opens
            show-hidden-files = true;
          };

          # File chooser
          "org/gtk/settings/file-chooser" = {
            show-hidden = true;
          };

          # Keyboard layouts
          "org/gnome/desktop/input-sources" = {
            sources = [
              (hm.gvariant.mkTuple [ "xkb" "us+mac" ])
              (hm.gvariant.mkTuple [ "xkb" "cz+qwerty-mac" ])
            ];
            xkb-options = [ "grp:alt_shift_toggle" ];
          };

          # Free Super+grave for Guake (default switches app group)
          "org/gnome/desktop/wm/keybindings" = {
            switch-group = [ ];
            switch-group-backward = [ ];
            switch-applications = [ ];
            switch-applications-backward = [ ];
            switch-windows = [ "<Alt>Tab" ];
            switch-windows-backward = [ "<Shift><Alt>Tab" ];
          };
        };
      };
    }
  ]));
}
