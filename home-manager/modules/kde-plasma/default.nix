# TODO: Split Klipper and whatnot into separate modules, keep configuration as a configuration

{ config, pkgs, lib, fop-utils, ... }:
let
  cfg = config.programs.plasma;

  stickyWindowSnappingSource = pkgs.fetchzip {
    url = "https://github.com/Flupp/sticky-window-snapping/archive/refs/tags/v1.0.1.zip";
    sha256 = "sha256-RZ5J5wSoyj36e8yPBEy4G4KWpvR1up3u8xjQea0oCNc=";
    extension = "zip";
    stripRoot = true;
  };
in
with lib; {
  imports = [ ./config-kwin.nix ];

  options = {
    programs.plasma = {
      # Enable inherited from plasma-manager

      useCustomConfig = mkOption {
        # TODO: Split into more parts (Klipper, theming, whatnot)
        type = types.bool;
        default = false;
      };

      virtualKeyboard = { enable = mkEnableOption "Virtual keyboard setup"; };

      calendarIntegration = {
        enable = mkEnableOption "Akonadi calendar integration";
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.useCustomConfig) (fop-utils.recursiveMerge [
      {
        home.packages = with pkgs; [
          # Themes | TODO: Add into custom config as inputs
          libsForQt5.kde-gtk-config
          plasmadeck
          papirus-icon-theme

          glxinfo # Enable OpenGL info integration
        ];

        # Dolphin global "Show hidden files"
        home.file."Dolphin global directory settings" = {
          target = ".local/share/dolphin/view_properties/global/.directory";
          text = lib.generators.toINI { } { Settings.HiddenFilesShown = true; };
        };

        programs.plasma = {
          configFile = {

            # Globals
            kdeglobals = {
              General = {
                ColorScheme = "PlasmaDeck";

                # TODO: Check if this could cause issues since it should be generated
                ColorSchemeHash = "01662607e36cd33eacc7d7d7189f69c26b9a2cc8";
              };
              KDE = {
                LookAndFeelPackage = "org.kde.breezedark.desktop";
                widgetStyle = "Breeze";

                # Single-click selects files, double-click opens
                SingleClick = false;
              };
              KScreen = {
                ScreenScaleFactors = "eDP=1.5;DisplayPort-0=1;";

                # Workaround for Steam etc scaling issue
                XwaylandClientsScale = false;
              };
              Icons = { Theme = "Papirus-Dark"; };
            };

            # Desktop
            plasmarc = {
              Theme.name = "PlasmaDeck"; # TODO: theme-specific
            };
            plasma-localerc = {
              Formats = {
                LANG = "en_DK.UTF-8";
                LC_TIME = "C";
              };
            };

            # Lock screen
            kscreenlockerrc = {
              Greeter.Theme = "PlasmaDeck"; # TODO: theme-specific
            };

            # Splash screen
            ksplashrc = {
              KSplash = {
                Engine = "KSplashQML";
                Theme = "org.kde.breeze.desktop";
              };
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

                # Allow specific folder sorting and whatnot
                ConfirmClosingMultipleTabs = false;

                # Short path in location unless expanded
                ShowFullPath = false;
              };
            };

            # Input
            kcminputrc = {
              "Libinput.10462.4613.Valve Software Steam Controller" = {
                PointerAcceleration = 0;
                PointerAccelerationProfile = 1; # Flat better
              };
              "Libinput.6940.7014.Corsair CORSAIR IRONCLAW RGB WIRELESS Gaming Dongle" =
                {
                  PointerAcceleration = -0.2;
                  PointerAccelerationProfile = 1;
                };
              Mouse = {
                X11LibInputXAccelProfileFlat = false;
                XLbInptAccelProfileFlat = true;
                XLbInptPointerAcceleration = -0.6;
                cursorTheme = "Breeze_Snow";
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
            kglobalshortcutsrc = {
              "KDE Keyboard Layout Switcher" = {
                "Switch to Next Keyboard Layout" =
                  "Meta+Space,Meta+Alt+K,Switch to Next Keyboard Layout";
              };
            };

            # Keyboard layouts
            kxkbrc = {
              Layout = {
                Use = true;
                LayoutList = "us,cz";
                VariantList = "mac,qwerty-mac";
              };
            };

            # Power Management
            powermanagementprofilesrc = {
              # Always sleep when power button is pressed
              "AC.HandleButtonEvents".powerButtonAction = 1;
              "Battery.HandleButtonEvents".powerButtonAction = 1;
              "LowBattery.HandleButtonEvents".powerButtonAction = 1;
            };

            # Notifications
            plasmanotifyrc = {
              Notifications.PopupPosition = "TopCenter";
            };

            # KRunner
            krunnerrc = {
              General = {
                FreeFloating = true; # Set KRunner to the center of the screen
                ActivityAware = true;
                HistoryEnabled = true;
                RetainPriorSearch = true;
              };
              Plugins = {
                baloosearchEnabled = true;
                locationsEnabled = true;
                recentdocumentsEnabled = false; # Nix store will force itself there 24/7 otherwise (despite indexing filters)
              };
            };

            ksmserverrc = {
              General = {
                loginMode = "emptySession";
                confirmLogout = false; # No point in clicking the same thing twice
              };
            };
            spectaclerc.General = {
              clipboardGroup =
                "PostScreenshotCopyImage"; # Copy screenshots to clipboard automatically
              useReleaseToCapture = true;
            };
            kded5rc = { Module-device_automounter.autoload = false; };
          };
        };
      }

      # Plugins
      {
        # TODO: Add a wrapper function for KWin scripts
        home.file."KWin script - Sticky window snapping" = {
          target = ".local/share/kwin/scripts/sticky-window-snapping/";
          source =
            let
              src = pkgs.fetchzip {
                url = "https://github.com/Flupp/sticky-window-snapping/archive/refs/tags/v1.0.1.zip";
                sha256 = "sha256-RZ5J5wSoyj36e8yPBEy4G4KWpvR1up3u8xjQea0oCNc=";
                extension = "zip";
                stripRoot = true;
              };
            in
            "${src}/package/";
          recursive = true; # Fix for kwin not seeing it because of symlinked directories
        };
        programs.plasma.configFile.kwinrc = {
          Plugins.sticky-window-snappingEnabled = true; # Auto-enable
        };
      }
    ]))
    (mkIf (cfg.enable && cfg.calendarIntegration.enable) {
      home.packages = with pkgs; [
        # Calendar integration
        # TODO: These link into `enabledCalendarPlugins` under applets config
        libsForQt5.kdepim-runtime
        libsForQt5.kdepim-addons
        libsForQt5.kalendar
        libsForQt5.akonadi
        libsForQt5.akonadi-calendar
      ];
    })
    (mkIf (cfg.enable && cfg.virtualKeyboard.enable) {
      home.packages = with pkgs; [ maliit-keyboard ];

      programs.plasma.configFile.kwinrc.Wayland = {
        InputMethod =
          "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
        VirtualKeyboardEnabled = true;
      };
      dconf.settings = {
        "org/maliit/keyboard/maliit" = {
          key-press-haptic-feedback = true;
          theme = "BreezeDark";
        };
      };
    })
  ];
}
