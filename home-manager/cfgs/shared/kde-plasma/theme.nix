{ config, pkgs, fop-utils, lib, cfg, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf mkDefault generators;
in
{
  options.flake-configs.plasma.theme = {
    enable = mkEnableOption "Custom Plasma theme configuration";
    package = mkOption {
      type = types.package;
      default = pkgs.materia-kde-theme;
    };
    accentColor = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config =
    let
      themePackage = config.flake-configs.plasma.theme.package;
      cursorTheme = "Breeze_Light";
      cursorSize = 24;
    in
    mkIf (cfg.enable && cfg.theme.enable) {
      home.packages = with pkgs; [
        (flat-remix-icon-theme.overrideAttrs (old: rec {
          version = "20251119";
          src = pkgs.fetchFromGitHub {
            owner = "daniruiz";
            repo = "flat-remix";
            rev = version;
            sha256 = "sha256-tQCzxMz/1dCsPSZHJ9bIWCRjPi0sS7VhRxttzzA7Tr4=";
          };
        }))
        themePackage

        kdePackages.qtwebengine
        kde.plugins.html-wallpaper
      ];

      home.pointerCursor = {
        package = pkgs.kdePackages.breeze;
        name = cursorTheme;
        size = cursorSize;
        gtk.enable = true;
        x11.enable = true;
      };

      qt = {
        enable = true;
        style.name = "kvantum";
      };
      xdg.configFile."Kvantum/kvantum.kvconfig".text = generators.toINI { } {
        General.theme = "MateriaDark";
      };

      programs.plasma = {
        workspace = {
          theme = "Materia-Color";
          colorScheme = "MateriaDark";
          lookAndFeel = null; # Changes every other option otherwise
          iconTheme = "Flat-Remix-Blue-Dark";
          windowDecorations = {
            library = "org.kde.kwin.aurorae";
            theme = "__aurorae__svg__Materia-Dark";
          };
          cursor = {
            theme = cursorTheme;
            size = cursorSize;
          };
          wallpaper = mkDefault ./wallpaper.svg; # NOTE: Not actually used, will be overwritten by custom script below
          soundTheme = "ocean";
        };

        # SVG wallpaper rendering in plasma is stupid - HTML wallpaper uses QtWebEngine, which uses Skia, which renders SVGs with dynamic dithering -> good
        startup.desktopScript."wallpaper_picture_direct" = {
          text =
            let
              pluginName = pkgs.kde.plugins.html-wallpaper.pluginName;

              # Remap local reference to a store one (mostly because I want to see the changes locally too :3)
              html = builtins.toFile "wallpaper.html" (
                builtins.replaceStrings
                  [ "./wallpaper.svg" ]
                  [ "file://${./wallpaper.svg}" ]
                  (builtins.readFile ./wallpaper.html)
              );
            in
            ''
              let allDesktops = desktops();
              for (const desktop of allDesktops) {
                desktop.wallpaperPlugin = "${pluginName}";
                desktop.currentConfigGroup = ["Wallpaper", "${pluginName}", "General"];
                desktop.writeConfig("DisplayPage", "file://${html}");
              }
            '';
          priority = 4;
        };

        kscreenlocker.appearance = {
          wallpaper = mkDefault "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
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
          (fop-utils.recursiveMerge [

            (fop-utils.mkOverrideRecursively 900 {
              "gtk-3.0/settings.ini" = gtkSettings;
              "gtk-4.0/settings.ini" = gtkSettings;
            })

            # Theme additionals
            {
              kdeglobals = {
                KDE.widgetStyle = "kvantum-dark";

                General = {
                  AccentColor = cfg.theme.accentColor;
                  /* NOTE: For color scheme leave AccentColor empty
                           For wallpaper `accentColorFromWallpaper=true` */
                };
              };

              # Set recommended borders
              kwinrc."org.kde.kdecoration2" = {
                BorderSize = "None";
                BorderSizeAuto = false;
              };
            }

            # Breeze window decoration settings
            # NOTE: Leftovers
            {
              breezerc = {
                Common = {
                  OutlineCloseButton = false;
                  ShadowSize = "ShadowSmall";
                  ShadowStrength = 255; #0-255 0-100%
                  OutlineIntensity = "OutlineLow";
                };
                Windeco = {
                  ButtonSize = "ButtonMedium";
                  TitleAlignment = "AlignCenterFullWidth";
                  DrawBackgroundGradient = false;
                  DrawBorderOnMaximizedWindows = false;
                };
              };
            }
          ]);
      };
    };
}
