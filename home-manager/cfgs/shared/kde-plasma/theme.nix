{ config, pkgs, fop-utils, lib, cfg, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf mkDefault;
in
{
  options.flake-configs.plasma.theme = {
    enable = mkEnableOption "Custom Plasma theme configuration";
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.klassy;
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
        kde.themes.eclipse-shade # For Plasma style

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

      programs.plasma = {
        workspace = {
          theme = "EclipseShade";
          colorScheme = "KritaDarkOrange"; # NOTE: Needs Krita installed
          lookAndFeel = null; # Changes every other option otherwise
          iconTheme = "klassy-dark"; # Actual themes in configFile below due to icon generation
          windowDecorations = {
            library = "org.kde.klassy";
            theme = "Klassy";
          };
          cursor = {
            theme = cursorTheme;
            size = cursorSize;
          };
          wallpaper = mkDefault ./wallpaper.svg; # NOTE: Not actually used, will be overwritten by custom script below
          soundTheme = "ocean";
        };

        startup = {
          # SVG wallpaper rendering in plasma is stupid - HTML wallpaper uses QtWebEngine, which uses Skia, which renders SVGs with dynamic dithering -> good
          desktopScript."wallpaper_picture_direct" = {
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
                /*js*/''
                // nix subs
                const pluginName = "${pluginName}";
                const html = "${html}";

                let allDesktops = desktops();
                for (const desktop of allDesktops) {
                  desktop.wallpaperPlugin = pluginName;
                  desktop.currentConfigGroup = ["Wallpaper", pluginName, "General"];
                  desktop.writeConfig("DisplayPage", `file://${html}`);
                }
              '';
            priority = 4;
            runAlways = false;
          };

          # Generate system icons when the configuration changes
          startupScript."klassy_generate_icons" = {
            text = /*sh*/''
              klassy-settings --generate-system-icons
            '';
            priority = 8; # As late as possible
            runAlways = false;
          };
        };

        kscreenlocker.appearance = {
          wallpaper = mkDefault "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
          alwaysShowClock = true;
          showMediaControls = true;
        };

        configFile = (fop-utils.recursiveMerge [
          # Theme additionals
          {
            kdeglobals = {
              KDE.widgetStyle = "Klassy";

              General = {
                AccentColor = cfg.theme.accentColor;
                /* NOTE: For color scheme leave AccentColor empty
                         For wallpaper `accentColorFromWallpaper=true` */
              };
            };

            kwinrc = {
              "org.kde.kdecoration2" = {
                BorderSize = "None";
                BorderSizeAuto = false;
              };

              Plugins.blurEnabled = true; # Whatever tries to be transparent, just blur it
              Effect-blur = {
                BlurStrength = 15; # Max strength - practically solid
                NoiseStrength = 0; # Noise might be pointless
              };
            };

            "klassy/klassyrc" = {
              ButtonColors = {
                ButtonBackgroundOpacityActive = 60;
                ButtonIconColorsActive = "TitleBarText";
                CloseButtonIconColorActive = "AsSelected";
              };
              Windeco = {
                BoldButtonIcons = "BoldIconsHiDpiOnly";
                ButtonIconStyle = "StyleFluent";
                DrawTitleBarSeparator = true;
              };
              WindowOutlineStyle = {
                ThinWindowOutlineStyleActive = "WindowOutlineShadowColor";
                ThinWindowOutlineStyleInactive = "WindowOutlineShadowColor";
                ThinWindowOutlineThickness = 1.75;
              };
              TitleBarOpacity = {
                ActiveTitleBarOpacity = 100;
                InactiveTitleBarOpacity = 100;
                ApplyOpacityToHeader = true;
                BlurTransparentTitleBars = false;
                OpaqueMaximizedTitleBars = true;
              };
              SystemIconGeneration = {
                KlassyIconThemeInherits = "Flat-Remix-Grey-Light";
                KlassyDarkIconThemeInherits = "Flat-Remix-Grey-Dark";
              };
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
