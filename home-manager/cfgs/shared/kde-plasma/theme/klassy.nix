# Configuration files used for klassy

{ cfg, lib, ... }:
let
  inherit (lib) mkIf recursiveUpdate;

  opalTwilightPreset = {
    TitleBar = {
      ActiveTitleBarOpacity = 100;
      InactiveTitleBarOpacity = 100;
      OverrideActiveTitleBarOpacity = false;
      OverrideInactiveTitleBarOpacity = false;

      DrawTitleBarSeparator = true;
      ApplyOpacityToHeader = true;
      BlurTransparentTitleBars = true;
      OpaqueMaximizedTitleBars = true;

      TitleAlignment = "AlignCenterFullWidth";

      TitleBarTopMargin = 2;
      TitleBarBottomMargin = 2;
      TitleBarLeftMargin = 0;
      TitleBarRightMargin = 0;
      TitleSidePadding = 2;

      PercentMaximizedTopBottomMargins = 85;

      LockTitleBarLeftRightMargins = true;
      LockTitleBarTopBottomMargins = true;
    };

    Buttons = {
      ButtonShape = "ShapeIntegratedRoundedRectangle";
      ButtonCornerRadius = "SameAsWindow";
      ButtonCustomCornerRadius = 2.5;

      ButtonSpacingLeft = 3;
      ButtonSpacingRight = 5;
      SpacerButtonWidthRelative = 33;

      FullHeightButtonSpacingLeft = 2;
      FullHeightButtonSpacingRight = 2;
      FullHeightButtonWidthMarginLeft = 4;
      FullHeightButtonWidthMarginRight = 9;
      CloseFullHeightButtonWidthMarginRelative = 100;

      LockButtonSpacingLeftRight = false;
      LockFullHeightButtonSpacingLeftRight = true;
      LockFullHeightButtonWidthMargins = false;
    };

    ButtonBehavior = {
      ButtonStateCheckedActive = "Press";
      ButtonStateCheckedInactive = "Press";

      LockButtonBehaviourActiveInactive = true;
      LockCloseButtonBehaviourActive = true;
      LockCloseButtonBehaviourInactive = true;
    };

    ButtonIcons = {
      BoldButtonIcons = "BoldIconsFine";
      ButtonIconStyle = "StyleMetro";

      IconSize = "IconLargeMedium";
      SystemIconSize = "SystemIcon16";

      ButtonIconOpacityActive = 100;
      ButtonIconOpacityInactive = 50;

      CloseButtonIconColorActive = "WhiteWhenHoverPress";
      CloseButtonIconColorInactive = "WhiteWhenHoverPress";
    };

    ButtonColors = {
      ButtonBackgroundColorsActive = "AccentTrafficLights";
      ButtonBackgroundColorsInactive = "AccentTrafficLights";
      ButtonBackgroundOpacityActive = 60;
      ButtonBackgroundOpacityInactive = 60;

      ButtonIconColorsActive = "AccentTrafficLights";
      ButtonIconColorsInactive = "TitleBarText";

      LockButtonColorsActiveInactive = false;
    };

    Colors = {
      UseHoverAccentActive = false;
      UseHoverAccentInactive = false;

      VaryColorBackgroundActive = "Opaque";
      VaryColorBackgroundInactive = "Opaque";
      VaryColorIconActive = "No";
      VaryColorIconInactive = "No";
      VaryColorOutlineActive = "Opaque";
      VaryColorOutlineInactive = "Opaque";

      VaryColorCloseBackgroundActive = "Transparent";
      VaryColorCloseBackgroundInactive = "Transparent";
      VaryColorCloseIconActive = "No";
      VaryColorCloseIconInactive = "No";
      VaryColorCloseOutlineActive = "Transparent";
      VaryColorCloseOutlineInactive = "Transparent";
    };

    WindowOutline = {
      ThinWindowOutlineThickness = 1.75;

      ThinWindowOutlineStyleActive = "WindowOutlineShadowColor";
      ThinWindowOutlineStyleInactive = "WindowOutlineShadowColor";

      ThinWindowOutlineCustomColorActive = "0,0,0";
      ThinWindowOutlineCustomColorInactive = "0,0,0";

      LockThinWindowOutlineCustomColorActiveInactive = true;
      LockThinWindowOutlineStyleActiveInactive = false;

      WindowOutlineShadowColorOpacity = 20;

      WindowOutlineContrastOpacityActive = 25;
      WindowOutlineContrastOpacityInactive = 25;

      WindowOutlineAccentColorOpacityActive = 67;
      WindowOutlineAccentColorOpacityInactive = 25;

      WindowOutlineAccentWithContrastOpacityActive = 50;
      WindowOutlineAccentWithContrastOpacityInactive = 20;

      WindowOutlineCustomColorOpacityActive = 60;
      WindowOutlineCustomColorOpacityInactive = 25;

      WindowOutlineCustomWithContrastOpacityActive = 40;
      WindowOutlineCustomWithContrastOpacityInactive = 25;
    };

    Shadows = {
      ShadowSize = "ShadowLarge";
      ShadowStrength = 255;
      ShadowColor = "0,0,0";
    };

    Window = {
      WindowCornerRadius = 2.5;
      UseTitleBarColorForAllBorders = true;
      DrawBorderOnMaximizedWindows = false;
      RoundBottomCornersWhenNoBorders = false;
    };

    Behavior = {
      AnimationsEnabled = true;
      AnimationsSpeedRelativeSystem = 0;

      AdjustBackgroundColorOnPoorContrastActive = true;
      AdjustBackgroundColorOnPoorContrastInactive = true;

      OnPoorIconContrastActive = "TitleBarBackground";
      OnPoorIconContrastInactive = "TitleBarBackground";

      PoorBackgroundContrastThresholdActive = 1.1;
      PoorBackgroundContrastThresholdInactive = 1.1;

      PoorIconContrastThresholdActive = 1.5;
      PoorIconContrastThresholdInactive = 1.5;
    };
  };
in
{
  config = mkIf (cfg.enable && cfg.theme.enable) {
    programs.plasma = {
      # Generate system icons when the configuration changes
      startup.startupScript."klassy_generate_icons" = {
        text = /*sh*/''
          klassy-settings --generate-system-icons
        '';
        priority = 8; # As late as possible
        runAlways = false;
      };

      configFile."klassy/klassyrc" = recursiveUpdate opalTwilightPreset {
        ButtonColors = {
          LockButtonColorsActiveInactive = true; # Sync active inactive overrides

          ButtonBackgroundOpacityActive = 60;
          ButtonIconColorsActive = "TitleBarText";
          CloseButtonIconColorActive = "AsSelected";
          CloseButtonIconColorInactive = "AsSelected";

          OnPoorIconContrastActive = "Nothing";
          OnPoorIconContrastInactive = "Nothing";
          AdjustBackgroundColorOnPoorContrastActive = false;
          AdjustBackgroundColorOnPoorContrastInactive = false;
        }
        # Make selected buttons white when hovered or clicked
        // (
          let
            mkButtonOverrideColors = buttons:
              let
                states = [ "Active" "Inactive" ];
                mkOne = state: button: {
                  name = "ButtonOverrideColors${state}${button}";
                  value = lib.generators.toJSON { } {
                    "IconHover" = [ "White" ];
                    "IconPress" = [ "White" ];
                  };
                };
              in
              builtins.listToAttrs (
                builtins.concatLists (
                  map (state: map (button: mkOne state button) buttons) states
                )
              );
          in
          mkButtonOverrideColors [
            "Minimize"
            "Maximize"
            "Close"

            "ApplicationMenu"
            "ContextHelp"
            "KeepAbove"
            "KeepBelow"
            "Menu"
            "OnAllDesktops"
            "Shade"
          ]
        );
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
    };
  };
}
