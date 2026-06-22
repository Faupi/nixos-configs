args@{ config, pkgs, fop-utils, lib, cfg, ... }:
let
  inherit (lib) types mkOption mkEnableOption mkIf mkDefault;
in
{
  imports = map (mod: (import mod args)) [
    ./klassy.nix
  ];

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
      iconPackage = (pkgs.flat-remix-icon-theme.overrideAttrs (old: rec {
        version = "20251119";
        src = pkgs.fetchFromGitHub {
          owner = "daniruiz";
          repo = "flat-remix";
          rev = version;
          sha256 = "sha256-tQCzxMz/1dCsPSZHJ9bIWCRjPi0sS7VhRxttzzA7Tr4=";
        };
      }));
      cursorTheme = "Breeze_Light";
      cursorSize = 24;
    in
    mkIf (cfg.enable && cfg.theme.enable) {
      home.packages = with pkgs; [
        themePackage
        iconPackage

        # For Plasma style
        kde.themes.materia

        kdePackages.qtwebengine
      ];

      home.pointerCursor = {
        package = pkgs.kdePackages.breeze;
        name = cursorTheme;
        size = cursorSize;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;
        colorScheme = "dark";
        theme = {
          package = pkgs.kdePackages.breeze-gtk;
          name = "Breeze";
        };
        iconTheme = {
          package = iconPackage;
          name = "Flat-Remix-Grey-Dark";
        };
        font = {
          # too lazy to keep it in sync
          name = builtins.head config.fonts.fontconfig.defaultFonts.sansSerif;
          size = 10;
        };
        gtk3 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
        gtk4 = {
          theme = config.gtk.theme;
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
      };

      programs.plasma = {
        workspace = {
          theme = "Materia-Color";
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
          wallpaper = fop-utils.rasterizeSVG pkgs {
            svg = "${fop-utils.assetsPath}/fox-wallpaper.svg";
            width = 2560;
            height = 1440;
          };
          soundTheme = "ocean";
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

              Plugins.blurEnabled = false; # Whatever tries to be transparent, just blur it
              Effect-blur = {
                BlurStrength = 15; # Max strength - practically solid
                NoiseStrength = 0; # Noise might be pointless
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
