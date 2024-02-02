# TODO: Split Klipper and whatnot into separate modules, keep configuration as a configuration

{ config, pkgs, lib, fop-utils, ... }:
let
  cfg = config.programs.plasma;
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
          papirus-icon-theme
          plasmadeck-vapor-theme # TODO: theme-specific

          glxinfo # Enable OpenGL info integration
        ];

        # Dolphin global "Show hidden files"
        home.file."Dolphin global directory settings" = {
          target = ".local/share/dolphin/view_properties/global/.directory";
          text = lib.generators.toINI { } { Settings.HiddenFilesShown = true; };
        };

        # Set up KRunner autostart so there's no waiting for the initial request
        home.file."KRunner autostart" = fop-utils.makeAutostartItemLink pkgs
          {
            name = "krunner";
            desktopName = "KRunner";
            exec = "krunner -d";
            extraConfig = {
              OnlyShowIn = "KDE";
            };
          }
          {
            systemWide = false;
          };

        programs.plasma = {
          configFile = {

            # Globals
            kdeglobals = {
              General = {
                ColorScheme = "Vapor"; # TODO: theme-specific
                # ColorSchemeHash needed?
              };
              KDE = {
                LookAndFeelPackage = "org.kde.breezedark.desktop"; # TODO: theme-specific
                widgetStyle = "Breeze"; # TODO: theme-specific

                # Single-click selects files, double-click opens
                SingleClick = false;
              };
              KScreen = {
                # Workaround for Steam etc scaling issue
                XwaylandClientsScale = false;
              };
              Icons = { Theme = "Papirus-Dark"; }; # TODO: theme-specific
            };

            # Desktop
            plasmarc = {
              Theme.name = "Vapor"; # TODO: theme-specific
            };
            plasma-localerc = {
              Formats = {
                LANG = "en_DK.UTF-8";
                LC_TIME = "C";
              };
            };

            # Lock screen
            kscreenlockerrc = {
              Greeter.Theme = "Vapor"; # TODO: theme-specific
              "Greeter.LnF.General".showMediaControls = false;

              # Double-escaping is dumb but works
              "Greeter.Wallpaper.org\\.kde\\.image.General" = {
                Image = "${pkgs.plasmadeck-vapor-theme}/share/wallpapers/Steam Deck Logo 5.jpg"; # TODO: theme-specific
                PreviewImage = "${pkgs.plasmadeck-vapor-theme}/share/wallpapers/Steam Deck Logo 5.jpg"; # TODO: theme-specific
              };
            };

            # Splash screen
            ksplashrc = {
              KSplash = {
                Engine = "KSplashQML";
                Theme = "com.valve.vapor.desktop"; # TODO: theme-specific
              };
            };

            "gtk-3.0/settings.ini" = {
              Settings.gtk-theme-name = "Vapor"; # TODO: theme-specific (if applicable)
            };
            "gtk-4.0/settings.ini" = {
              Settings.gtk-theme-name = "Vapor"; # TODO: theme-specific (if applicable)
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

            # Mouse & Touchpad
            kcminputrc = {
              "Libinput.10462.4613.Valve Software Steam Controller" = {
                PointerAcceleration = 0;
                PointerAccelerationProfile = 1; # Flat better
              };
              "Libinput.4660.22136.extest fake device" = {
                PointerAcceleration = -0.600;
                PointerAccelerationProfile = 2;
                ScrollFactor = 0.75;
              };

              "Libinput.6940.7014.Corsair CORSAIR IRONCLAW RGB WIRELESS Gaming Dongle" = {
                PointerAcceleration = -0.2;
                PointerAccelerationProfile = 1;
              };
              "Libinput.1133.49291.Logitech G502 HERO Gaming Mouse" = {
                PointerAcceleration = -0.800;
                PointerAccelerationProfile = 1;
              };

              Mouse = {
                X11LibInputXAccelProfileFlat = false;
                XLbInptAccelProfileFlat = true;
                XLbInptPointerAcceleration = -0.8;
                cursorTheme = "Breeze_Snow";
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
            kglobalshortcutsrc = {
              "KDE Keyboard Layout Switcher" = {
                "Switch to Next Keyboard Layout" =
                  "Meta+Space,Meta+Alt+K,Switch to Next Keyboard Layout";
              };
            };
            kwinrc = rec {
              ModifierOnlyShortcuts = {
                # Switch Meta from launcher to krunner
                Meta = "org.kde.krunner,/App,,toggleDisplay";
              };
              # Desktop effects
              Plugins = {
                diminactiveEnabled = true;
                kwin4_effect_dimscreenEnabled = true;

                desktopgridEnabled = false;
                presentwindowsEnabled = false;
              };
              Effect-diminactive = {
                Strength = 10;
                DimByGroup = true;
                DimFullScreen = true;
                DimKeepAbove = true;
                DimDesktop = false;
                DimPanels = false;
              };
              # Because why wouldn't Kubuntu have this specific section formatted in camel case instead
              Effect-DimInactive = Effect-diminactive;

              Wayland = {
                EnablePrimarySelection = false; # Disable middle-click to paste
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

            # Breeze window decors
            breezerc = {
              "Common" = {
                OutlineCloseButton = true;
                ShadowSize = "ShadowSmall";
              };
            };

            ksmserverrc = {
              General = {
                loginMode = "emptySession";
                confirmLogout = false; # No point in clicking the same thing twice
              };
            };
            spectaclerc.General = {
              clipboardGroup = "PostScreenshotCopyImage"; # Copy screenshots to clipboard automatically
              useReleaseToCapture = true;
            };
            kded5rc = { Module-device_automounter.autoload = false; };
          };
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
      # TODO: Fix the dumb log spam
      home.packages = with pkgs; [ maliit-keyboard ];

      programs.plasma.configFile.kwinrc.Wayland = {
        InputMethod = "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
        VirtualKeyboardEnabled = true;
      };

      dconf = {
        enable = true;
        settings = {
          "org.maliit.keyboard.maliit" = {
            key-press-haptic-feedback = true;
            theme = "BreezeDark";
          };
        };
      };
    })
  ];
}
