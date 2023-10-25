# TODO: Split Klipper and whatnot into separate modules, keep configuration as a configuration

{ config, pkgs, lib, ... }:
let cfg = config.programs.plasma;
in with lib; {
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
    (mkIf (cfg.enable && cfg.useCustomConfig) {
      home.packages = with pkgs; [
        # Klipper utils
        htmlq
        jq

        # Themes | TODO: Add into custom config as inputs
        libsForQt5.kde-gtk-config
        plasmadeck
        papirus-icon-theme

        glxinfo # Enable OpenGL info integration
      ];

      # Dolphin global "Show hidden files"
      home.file.".local/share/dolphin/view_properties/global/.directory".text =
        lib.generators.toINI { } { Settings.HiddenFilesShown = true; };

      programs.plasma = {
        configFile = {
          # Globals
          kdeglobals = {
            General = {
              ColorScheme = "PlasmaDeck";
              ColorSchemeHash =
                "01662607e36cd33eacc7d7d7189f69c26b9a2cc8"; # 0xBAD This might not be a great idea
            };
            KDE = {
              LookAndFeelPackage = "org.kde.breezedark.desktop";
              SingleClick =
                false; # Single-click selects files, double-click opens
              widgetStyle = "Breeze";
            };
            KScreen = {
              ScreenScaleFactors = "eDP=1.5;DisplayPort-0=1;";
              XwaylandClientsScale =
                false; # Workaround for Steam etc scaling issue
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
            General = {
              dbVersion = 2;
              "exclude filters" =
                "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.venv,venv,core-dumps,lost+found";
              "exclude filters version" = 8;
            };
          };
          # Doplhin file explorer
          dolphinrc = {
            "KFileDialog Settings" = {
              "Places Icons Auto-resize" = false;
              "Places Icons Static Size" = 22;
            };
            General.GlobalViewProps =
              false; # Allow specific folder sorting and whatnot
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
          kded5rc = { Module-device_automounter.autoload = false; };
          # Keyboard layouts
          kxkbrc = {
            Layout = {
              Use = true;
              LayoutList = "us,cz";
              VariantList = "mac,qwerty-mac";
            };
          };
          spectaclerc.General = {
            clipboardGroup =
              "PostScreenshotCopyImage"; # Copy screenshots to clipboard automatically
            useReleaseToCapture = true;
          };
        };
      };
    })
    (mkIf (cfg.enable && cfg.calendarIntegration.enable) {
      home.packages = with pkgs; [
        # Calendar integration | TODO: These link into `enabledCalendarPlugins` under applets config
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
    })
  ];
}