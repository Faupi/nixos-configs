args@{ config, lib, pkgs, ... }:
let
  inherit (lib) hm mkEnableOption mkIf mkMerge;

  cfg = config.flake-configs.gnome;
  wallpaperSrc = ../kde-plasma/theme/wallpaper.svg;
  wallpaperRelPath = "backgrounds/plasma-wallpaper.svg";
  wallpaperUri = "file://${config.xdg.dataHome}/${wallpaperRelPath}";
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
      xdg.dataFile.${wallpaperRelPath}.source = wallpaperSrc;

      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };

      dconf = {
        enable = true;
        settings = {
          # Keep GNOME overview on Super
          "org/gnome/mutter" = {
            overlay-key = "Super_L";
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/"
            ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle" = {
            name = "Guake toggle";
            command = "guake -t";
            binding = "<Super>grave";
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
            font-antialiasing = "rgba";
            font-hinting = "slight";
            text-scaling-factor = 1.0;
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
            xkb-options = [ "grp:win_switch" ];
          };
        };
      };
    }
  ]));
}
