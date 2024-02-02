{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kde-bismuth # Custom packaging -> pkgs/kde-bismuth/default.nix
  ];

  # TODO: Add kwin rule for minimal window size (kwin rules need a proper module home-manager/modules/kde-plasma/config-kwin.nix)

  programs.plasma.configFile.kwinrc = {
    Plugins.bismuthEnabled = true; # Auto-enable

    Script-bismuth = {
      enableTileLayout = true;
      enableMonocleLayout = true;
      enableSpiralLayout = false;
      enableSpreadLayout = false;
      enableStairLayout = false;
      enableThreeColumnLayout = false;
      enableQuarterLayout = false;
      enableFloatingLayout = false;

      maximizeSoleTile = true;
      noTileBorder = true;
      monocleMaximize = true;
      monocleMinimizeRest = false;
      layoutPerActivity = true;
      layoutPerDesktop = true;

      # Defaults because idk
      # <entry name="(\w+)"(?:.*)$.*\n.*\n\s+<default>(.*)<\/default>
      # bismuth/src/config/bismuth_config.kcfg
      ignoreActivity = "";
      ignoreClass = "yakuake,spectacle,Conky,zoom";
      ignoreRole = "quake";
      ignoreScreen = "";
      ignoreTitle = "";
      floatingClass = "";
      floatingTitle = "";
      floatUtility = true;
      untileByDragging = true;
      keepFloatAbove = true;
      preventMinimize = false;
      preventProtrusion = true;
      screenGapLeft = 0;
      screenGapRight = 0;
      screenGapTop = 0;
      screenGapBottom = 0;
      tileLayoutGap = 0;
      limitTileWidth = false;
      newWindowAsMaster = false;
      experimentalBackend = false;
    };

    # Focusing rules for good tiling usage
    Windows = {
      AutoRaise = true;
      AutoRaiseInterval = 0;
      DelayFocusInterval = 0;
      FocusPolicy = "FocusFollowsMouse";
      NextFocusPrefersMouse = true; # Mouse precedence

      # Open floating windows always in the center
      OpenGLIsUnsafe = true; # Restoring position
      Placement = "Centered";

      # Multi-screen
      SeparateScreenFocus = true;
    };
  };
}
