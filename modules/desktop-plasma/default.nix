{ config, pkgs, lib, plasma-manager, ... }:
with lib;
let 
  cfg = config.my.plasma;
in
{
  # TODO: require home-manager

  options.my.plasma = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    user = mkOption {
      type = types.str;
    };
    
    useCustomConfig = mkOption {
      # TODO: Split into more parts (Klipper, theming, whatnot)
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Display
      services.xserver = {
        enable = true;
        excludePackages = [ 
          pkgs.xterm
        ];
      };

      # Desktop
      services.xserver.desktopManager.plasma5.enable = true;
      environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        oxygen
        khelpcenter
        print-manager
      ];
    })
    (mkIf (cfg.enable && cfg.useCustomConfig) {
      home-manager.users."${cfg.user}" = {
        home.packages = with pkgs; [
          # Calendar integration | TODO: These link into `enabledCalendarPlugins` under applets config
          libsForQt5.kdepim-runtime
          libsForQt5.kdepim-addons
          libsForQt5.kalendar
          libsForQt5.akonadi
          libsForQt5.akonadi-calendar

          # Klipper utils
          htmlq
          jq

          # Themes | TODO: Add into custom config as inputs
          libsForQt5.kde-gtk-config
          plasmadeck
          papirus-icon-theme
          
          # Inputs | TODO: Maybe add a config option?
          maliit-keyboard
          
          glxinfo
        ];

        # Plasma-manager config
        imports = [
          plasma-manager.homeManagerModules.plasma-manager
        ];
        programs.plasma = {
          enable = true;
          configFile = mkMerge [
            # (import ./config-klipper.nix)  # TODO: Figure out workaround for `...[$e]` INI keys - they get escaped in shell, so Klipper isn't possible to set up properly
            (import ./config-kwin.nix { inherit lib; })
            {
              # Globals
              kdeglobals = {
                General = {
                  ColorScheme = "PlasmaDeck";
                  ColorSchemeHash = "01662607e36cd33eacc7d7d7189f69c26b9a2cc8";  # 0xBAD This might not be a great idea
                };
                KDE = {
                  LookAndFeelPackage = "org.kde.breezedark.desktop";
                  SingleClick = false;  # Single-click selects files, double-click opens
                  widgetStyle = "Breeze";
                };
                KScreen = {
                  ScreenScaleFactors = "eDP=1.5;DisplayPort-0=1;";
                  XwaylandClientsScale = false;  # Workaround for Steam etc scaling issue
                };
                Icons = {
                  Theme = "Papirus-Dark";
                };
              };
              # Desktop
              plasmarc = {
                Theme.name = "PlasmaDeck";  # TODO: theme-specific
              };
              plasma-localerc = {
                Formats = {
                  LANG = "en_DK.UTF-8";
                  LC_TIME = "C";
                };
              };
              plasmashellrc = {
                "PlasmaViews.Panel 72.Defaults".thickness = 46;  # Taskbar height
              };
              # Lock screen
              kscreenlockerrc = {
                Greeter.Theme = "PlasmaDeck";  # TODO: theme-specific
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
                  "exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.venv,venv,core-dumps,lost+found";
                  "exclude filters version" = 8;
                };
              };
              # Doplhin file explorer
              dolphinrc = {
                "KFileDialog Settings" = {
                  "Places Icons Auto-resize" = false;
                  "Places Icons Static Size" = 22;
                };
                General.GlobalViewProps = false;  # Allow specific folder sorting and whatnot
              };
              # Input
              kcminputrc = {
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
              kglobalshotcutsrc = {
                "KDE Keyboard Layout Switcher" = {
                  "Switch to Next Keyboard Layout" = "Meta+Space,Meta+Alt+K,Switch to Next Keyboard Layout";
                };
              };
              kded5rc = {
                Module-device_automounter.autoload = false;
              };
              # Taskbar + start menu
              "plasma-org.kde.plasma.desktop-appletsrc" = {
                "Containments.72.Applets.73.Configuration.General" = {
                  # "Highlight" session buttons
                  systemFavorites = "lock-screen\\,logout\\,save-session";
                  primaryActions = 1;
                };
                "Containments.72.Applets.75.Configuration.General" = {
                  groupedTaskVisualization = 1;  # Click on group shows previews
                  launchers = "preferred://filemanager,preferred://browser";  # Taskbar items
                };
                # Digital Clock
                "Containments.72.Applets.95.Configuration.Appearance" = {
                  use24hFormat = 2;  # Force 24h format specifically
                  dateFormat = "isoDate";  # ISO date - 2023-08-23
                };
                # Task indicators
                "Containments.78.General" = {
                  hiddenItems = "org.kde.kalendar.contact,org.kde.plasma.clipboard,org.kde.kscreen";
                };
              };
              # Clipboard manager
              klipperrc = {
                General = {
                  IgnoreImages = false;
                  KeepClipboardContents = false;
                  MaxClipItems = 10;
                  SyncClipboards = true;
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
              spectaclerc.General.clipboardGroup = "PostScreenshotCopyImage";  # Copy screenshots to clipboard automatically
            }
          ];
        };
      };
    })
  ];
}
