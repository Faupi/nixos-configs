{ config, pkgs, lib, inputs, ... }:
with lib;
let 
  cfg = config.my.plasma;
  hmPlasmaManager = inputs.plasma-manager.homeManagerModules.plasma-manager;
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

    virtualKeyboard = { 
      enable = mkOption {
        type = types.bool;
        default = true;
      };
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

      # Fonts
      fonts.fonts = with pkgs; [
        noto-fonts
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
          
          glxinfo  # Enable OpenGL info integration
        ];

        # Dolphin global "Show hidden files"
        home.file.".local/share/dolphin/view_properties/global/.directory".text = lib.generators.toINI {} {
          Settings.HiddenFilesShown = true;
        };

        # Plasma-manager config
        imports = [
          hmPlasmaManager
          ./config-kwin.nix
          ./config-klipper.nix
        ];
        programs.plasma = {
          enable = true;
          klipper = {
            actions = {
              "Spotify link" = {
                automatic = true;
                regexp = ''^https?://open\\.spotify\\.com/(track|album)/([0-9|a-z|A-Z]+)'';
                commands = {
                  "Play video" = {
                    command = ''curl https://api.song.link/v1-alpha.1/links/?url='%s' | jq -j '.linksByPlatform.youtube.url' | grep -Eo '^https://www.youtube.com/watch\?v=[a-zA-Z0-9_-]{11}$$' | xargs mpv --profile=builtin-pseudo-gui --fs'';
                    icon = "mpv";
                    output = 0;
                  };
                };
              };
              "Other link" = {
                automatic = true;
                regexp = ''^https?://whatthefuck\\.com/.*'';
                commands = {
                  "Funny" = {
                    command = ''alexa play despacito'';
                    icon = "mpv";
                    output = 0;
                  };
                  "Second funny" = {
                    command = ''intruder alert'';
                    icon = "biden";
                    output = 0;
                  };
                };
              };
            };
          };
          configFile = {
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
              "Libinput.10462.4613.Valve Software Steam Controller" = {
                PointerAcceleration = 0;
                PointerAccelerationProfile = 1;  # Flat better
              };
              "Libinput.6940.7014.Corsair CORSAIR IRONCLAW RGB WIRELESS Gaming Dongle" = {
                PointerAcceleration = -0.200;
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
                "Switch to Next Keyboard Layout" = "Meta+Space,Meta+Alt+K,Switch to Next Keyboard Layout";
              };
            };
            kded5rc = {
              Module-device_automounter.autoload = false;
            };
            # Taskbar + start menu
            "plasma-org.kde.plasma.desktop-appletsrc" = {
              # TODO: These containment IDs change - needs some INI filtering on install..
              # Actually maybe straight up just replace this one with a saved INI here.
              # Containments.3.Applets.4 plugin=org.kde.plasma.kickoff
              "Containments.3.Applets.4.Configuration.General" = {
                # "Highlight" session buttons
                systemFavorites = "lock-screen\\,logout\\,save-session";
                primaryActions = 1;
              };
              # Containments.3.Applets.6 plugin=org.kde.plasma.icontasks
              "Containments.3.Applets.6.Configuration.General" = {
                groupedTaskVisualization = 1;  # Click on group shows previews
                launchers = "preferred://filemanager,preferred://browser";  # Taskbar items
              };
              # Digital Clock
              # Containments.3.Applets.19 plugin=org.kde.plasma.digitalclock
              "Containments.3.Applets.19.Configuration.Appearance" = {
                use24hFormat = 2;  # Force 24h format specifically
                dateFormat = "isoDate";  # ISO date - 2023-08-23
              };
              # Task indicators
              # Containments.9 plugin=org.kde.plasma.private.systemtray
              "Containments.9.General" = {
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
            spectaclerc.General = {
              clipboardGroup = "PostScreenshotCopyImage";  # Copy screenshots to clipboard automatically
              useReleaseToCapture = true;
            };
          };
        };
      };
    })
    (mkIf (cfg.enable && cfg.virtualKeyboard.enable) {
      home-manager.users."${cfg.user}" = {
        home.packages = with pkgs; [
          maliit-keyboard
        ];

        imports = [
          hmPlasmaManager
        ];
        programs.plasma.configFile.kwinrc.Wayland = {
          # InputMethod[$e] = "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";  # TODO: Resolve `[$e]`
          VirtualKeyboardEnabled = true;
        };
      };
    })
  ];
}
