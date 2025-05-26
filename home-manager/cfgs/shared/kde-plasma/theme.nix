{ config, pkgs, fop-utils, lib, cfg, ... }:
{
  options.flake-configs.plasma.theme = {
    enable = lib.mkEnableOption "Custom Plasma theme configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kde.themes.carl;
    };
  };

  config =
    let
      themePackage = config.flake-configs.plasma.theme.package;
      cursorTheme = "Breeze_Light";
      cursorSize = 24;
    in
    lib.mkIf (cfg.enable && cfg.theme.enable) {
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
          inherit (themePackage) colorScheme theme;
          lookAndFeel = null; # Changes every other option otherwise
          iconTheme = "Papirus-Dark";
          windowDecorations = {
            library = "org.kde.breeze";
            theme = "Breeze";
          };
          cursor = {
            theme = cursorTheme;
            size = cursorSize;
          };
          wallpaper = lib.mkDefault ./wallpaper.svg;
        };
        # REVIEW: For some reason the SVG doesn't like the file:// URI prefix, so we override the already-set config without it
        # NOTE: We're not replacing the original since it sets fill mode etc.
        startup.desktopScript."wallpaper_picture_direct" = {
          text = ''
            let allDesktops = desktops();
            for (const desktop of allDesktops) {
              desktop.wallpaperPlugin = "org.kde.image";
              desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
              desktop.writeConfig("Image", "${toString config.programs.plasma.workspace.wallpaper}");
            }
          '';
          priority = 4;
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
          (fop-utils.recursiveMerge [

            (fop-utils.mkOverrideRecursively 900 {
              "gtk-3.0/settings.ini" = gtkSettings;
              "gtk-4.0/settings.ini" = gtkSettings;
            })
            {
              # Breeze window decoration settings
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
