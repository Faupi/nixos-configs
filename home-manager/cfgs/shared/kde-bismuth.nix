# Stupid workaround for the fact that Ubuntu doesn't play well with Nix-packaged Bismuth, so we have a wrapper for an argument to turn it off.
{ useNixBismuth ? true }:
(
  { pkgs, lib, fop-utils, ... }:
  with lib;
  (fop-utils.recursiveMerge [
    # Bismuth itself
    {
      home.packages = lists.optional useNixBismuth pkgs.kde-bismuth; # Custom packaging -> pkgs/kde-bismuth/default.nix

      # TODO: Shortcut setup

      programs.plasma = {
        kwin.rules = {
          "01 Bismuth tiling default" = {
            enable = true;
            extraConfig = {
              wmclassmatch = 0; # Class unimportant
              types = 1; # All normal windows

              # Force minimum size limit
              minsize = "100,10"; # 10px vertical important to not force content if the window just wants a "title" e.g. KRunner
              minsizerule = 2;
            };
          };
        };

        configFile.kwinrc = {
          Plugins = {
            bismuthEnabled = true; # Auto-enable Bismuth
            tileseditorEnabled = false; # Disable the Plasma tiling editor
          };

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
            noTileBorder = true; # Active accent frame overrides
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
            floatingClass = "org.kde.polkit-kde-authentication-agent-1,krunner";
            floatingTitle = "";
            floatUtility = true;
            untileByDragging = true;
            keepFloatAbove = false;
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
            AutoRaise = false;
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
      };
    }

    # Window decorations
    {
      programs.plasma.configFile.kwinrc = {
        "org\\.kde\\.kdecoration2" = fop-utils.mkForceRecursively {
          BorderSize = "Tiny"; # Enforce the actual size of the frame
          BorderSizeAuto = false;
          library = "org.kde.bismuth.decoration";
          theme = "Bismuth";
        };

        Script-bismuth = {
          noTileBorder = mkForce false; # Keep frames visible while tiled
          monocleMaximize = mkForce true; # No point of frames in fullscreen
        };
      };
    }
  ])
)
