args@{ config, pkgs, lib, fop-utils, ... }:
with lib;
let
  cfg = config.flake-configs.plasma;

  sharedOptions = {
    colorCPU = "87,118,182";
    colorGPU = "181,150,87";
    colorMemory = "168,101,157";
    colorSwap = "92,177,107";
  };

  sharedArgs = args // { inherit sharedOptions cfg; };
in
{
  options.flake-configs.plasma = {
    enable = mkEnableOption "Enable custom Plasma configuration";
    reloadOnActivation = lib.mkEnableOption "Whether to reload on config activation";
  };

  imports = [
    (import ./fonts.nix sharedArgs)
    (import ./klipper sharedArgs)
    (import ./konsole.nix sharedArgs)
    (import ./krunner sharedArgs)
    (import ./panels sharedArgs)
    (import ./powerdevil.nix sharedArgs)
    (import ./shortcuts.nix sharedArgs)
    (import ./spectacle.nix sharedArgs)
    (import ./tabbox.nix sharedArgs)
    (import ./theme sharedArgs)
    (import ./virtual-keyboard.nix sharedArgs)
    (import ./window-rules.nix sharedArgs)
    (import ./yakuake.nix sharedArgs)
  ];

  config = (lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        kdePackages.qtmultimedia # Needed for some widgets e.g. Fokus
      ];

      # Dolphin global "Show hidden files"
      xdg.dataFile."Dolphin global directory settings" = {
        target = "dolphin/view_properties/global/.directory";
        text = generators.toINI { } { Settings.HiddenFilesShown = true; };
      };

      programs.plasma = {
        enable = true;

        # NOTE: Modules can freely override, we're just overriding the default level
        configFile = fop-utils.mkOverrideRecursively 900 {

          # Globals
          kdeglobals = {
            KDE = {
              # Single-click selects files, double-click opens
              SingleClick = false;
            };
            KScreen = {
              # Legacy applications (X11): Apply scaling themselves
              # NOTE: Needed to expose native resolutions on fullscreen games
              # TODO: Flip back to false in 6.6
              XwaylandClientsScale = true;
            };
          };

          plasma-localerc = {
            Formats = {
              LANG = "en_DK.UTF-8";
              LC_TIME = "C";
            };
          };

          # Lock screen
          kscreenlockerrc = {
            "Greeter.LnF.General".showMediaControls = false;
          };

          # File search
          baloofilerc = {
            "Basic Settings" = {
              "Indexing-Enabled" = true;
            };
            General = {
              "exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.venv,venv,core-dumps,lost+found";
              "exclude filters version" = 8;
              "exclude folders" = "/nix/"; # Derivation nesting hell
            };
          };

          # Doplhin file explorer
          dolphinrc = {
            "KFileDialog Settings" = {
              "Places Icons Auto-resize" = false;
              "Places Icons Static Size" = 22;
            };
            General = {
              GlobalViewProps = false;
              RememberOpenedTabs = false;
              ShowFullPathInTitlebar = true;
              HomeUrl = config.home.homeDirectory;

              # Single-instance
              OpenExternallyCalledFolderInNewTab = true;

              # Allow specific folder sorting and whatnot
              ConfirmClosingMultipleTabs = false;

              # Short path in location unless expanded
              ShowFullPath = false;
            };
          };

          # Mouse & Touchpad
          kcminputrc = {
            # Controllers
            "Libinput/10462/4613/Valve Software Steam Controller" = {
              PointerAcceleration = 0;
              PointerAccelerationProfile = 1; # Flat better
            };
            "Libinput/4660/22136/extest fake device" = {
              PointerAcceleration = -0.600;
              PointerAccelerationProfile = 2;
              ScrollFactor = 0.75;
            };

            # Mice
            "Libinput/6940/7014/Corsair CORSAIR IRONCLAW RGB WIRELESS Gaming Dongle" = {
              PointerAcceleration = -0.2;
              PointerAccelerationProfile = 1;
            };
            "Libinput/1133/49291/Logitech G502 HERO Gaming Mouse" = {
              PointerAcceleration = -0.800;
              PointerAccelerationProfile = 1;
            };
            "Libinput/1256/28705/Wireless Keyboard Mouse" = {
              # Technically a touchpad, but oh well
              NaturalScroll = true;
              PointerAcceleration = -0.600;
            };

            # Touchpads
            "Libinput/1267/12868/ELAN079C:00 04F3:3244 Touchpad" = {
              ClickMethod = 2;
              NaturalScroll = true;
              PointerAcceleration = -0.200;
              PointerAccelerationProfile = 2;
              ScrollFactor = 0.5;
              TapDragLock = true;
              TapToClick = true;
            };
            "Libinput/1256/28705/Wireless Keyboard" = {
              NaturalScroll = true;
              PointerAccelerationProfile = 1;
            };

            Mouse = {
              X11LibInputXAccelProfileFlat = false;
              XLbInptAccelProfileFlat = true;
              XLbInptPointerAcceleration = -0.8;
            };
          };
          touchpadxlibinputrc = {
            "VEN_06CB:00 06CB:CE65 Touchpad" = {
              clickMethodAreas = true;
              clickMethodClickfinger = false;
              naturalScroll = true;
              tapAndDrag = true;
              tapDragLock = false;
              tapToClick = true;
            };
          };

          # Hotkeys/input
          khotkeysrc = {
            Gestures = {
              Disabled = true;
              MouseButton = 2;
              Timeout = 300;
            };
          };
          kwinrc = rec {
            # Desktop effects
            Plugins = {
              diminactiveEnabled = true;
              kwin4_effect_dimscreenEnabled = true;

              desktopgridEnabled = false;
              presentwindowsEnabled = false;

              # Virtual desktop switching animations
              slideEnabled = true;
              fadedesktopEnabled = false;
            };
            Effect-diminactive = {
              Strength = 10;
              DimByGroup = true;
              DimKeepAbove = true;
              DimFullScreen = false; # Mostly important for videos and games -> multi-screen
              DimDesktop = false;
              DimPanels = false;
            };
            # Because why wouldn't Kubuntu have this specific section formatted in camel case instead
            Effect-DimInactive = Effect-diminactive;

            Wayland = {
              # Enable middle-click to paste
              # - Avoids a few issues of the not-so-mature clipboard handling in KDE
              # Challenge: get used to it.
              EnablePrimarySelection = true;
            };

            Windows = {
              FocusStealingPreventionLevel = 0; # None
              # NOTE: Low seems to have recently changed and it applies to a lot of things, better to do specific overrides

              AutoRaise = false;
              AutoRaiseInterval = 0;
              DelayFocusInterval = 0;
              FocusPolicy = "ClickToFocus";
              NextFocusPrefersMouse = true; # Mouse precedence

              OpenGLIsUnsafe = true; # Restoring position
              Placement = "Centered"; # NOTE: Maximizing causes problems with Klipper context menus

              # Multi-screen
              SeparateScreenFocus = false;
            };

            Compositing.WindowsBlockCompositing = true;
            # ^ Was a fix for tearing, but GPU drivers fixed it - games run mega smooth with it on
            Desktops.Rows = 1;
            Tiling.padding = 4;
            Input.TabletMode = "auto";
            Effect-windowview.BorderActivateAll = 9; # Disable top-left corner

            # Window decorations
            # TODO: Convert to plasma-manager options?
            "org.kde.kdecoration2" = {
              ButtonsOnLeft = "MF"; # Window menu, Keep above
              ButtonsOnRight = "IAX"; # Minimize, Maximize, Close
              ShowToolTips = false; # Avoid lingering tooltips when moving cursor to another display (something like Windows)
            };

            MouseBindings = {
              # 1 = Left
              # 2 = Middle
              # 3 = Right
              # Wheel = Scrolling

              CommandWindow1 = "Activate, raise and pass click";
              CommandWindow2 = "Activate, raise and pass click";
              CommandWindow3 = "Activate, raise and pass click";
              CommandWindowWheel = "Scroll";

              CommandAll1 = "Move";
              CommandAll2 = "Minimize";
              CommandAll3 = "Resize";
              CommandAllWheel = "Maximize/Restore";
            };

            EdgeBarrier = {
              EdgeBarrier = 0; # By default there's already a meaningful amount
            };
          };

          # Keyboard layouts
          kxkbrc = {
            Layout = {
              Use = true;
              LayoutList = "us,cz";
              VariantList = "mac,qwerty-mac";
              SwitchMode = "WinClass";
            };
          };

          # Notifications
          plasmanotifyrc = {
            Notifications.PopupPosition = "BottomRight";
            DoNotDisturb.WhenFullscreen = false; # Don't DND when a fullscreen application is focused
          };

          ksmserverrc = {
            General = {
              loginMode = "emptySession";
              confirmLogout = false; # No point in clicking the same thing twice
            };
          };
          kded5rc = { Module-device_automounter.autoload = false; };

          kwalletrc = {
            Wallet.Enabled = true;
          };
        };
      };
    }

    (lib.mkIf cfg.reloadOnActivation {
      home.activation.activate-plasma =
        let
          exposedPackages = with pkgs; [
            kdePackages.qttools # qdbus for calling plasma scripts
            systemdMinimal # systemctl for restarting services
          ];
        in
        lib.hm.dag.entryAfter [ "configure-plasma" "linkGeneration" ] ''
          PATH="$PATH:${lib.makeBinPath exposedPackages}" bash $HOME/.local/share/plasma-manager/run_all.sh
        '';
    })
  ]));
}
