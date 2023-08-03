{ config, pkgs, lib, plasma-manager, ... }:

# TODO:
#   Rest of KDE setup (localization, whatnot)
#   oh-my-posh
#   Discord
#   Audio enhancements (mic boost + noise cancellation VST)

let 
  moonlight-mic-wrapper = pkgs.makeDesktopItem {
    name = "com.moonlight_stream.Moonlight";
    comment = "Stream games from your NVIDIA GameStream-enabled PC";
    desktopName = "Moonlight (with mic)";
    exec = ''
      trap 'kill %1' SIGINT
      ffmpeg -ac 1 -f pulse -i default -acodec mp2 -ac 1 -f rtp rtp://192.168.88.254:25000 & moonlight
    '';
    terminal = false;
    icon = "moonlight";
    type = "Application";
    categories = [ "Qt" "Game" ];
    keywords = [ "nvidia" "gamestream" "stream" ];
  };
in
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ]; 

  # TODO: Slap into custom wrapper
  networking.hostName = "deck";
  networking.networkmanager.enable = true;

  # Gamestreaming mic passthrough RTP
  networking.firewall.allowedUDPPorts = [ 25000 ];
  
  services.openssh.enable = true;  # TODO: Remove when installed

  # Display
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;  # Fix for touchscreen matrix, otherwise unneeded
        autoLogin.delay = 0;  # GDM needs > 0 for autologin after logout - workaround is to restart the service
      };
      autoLogin = {
        enable = true;
        user = "faupi";
      };
    };
    excludePackages = [ 
      pkgs.xterm
    ];
  };
  # Workaround for GDM autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Desktop
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    oxygen
    khelpcenter
    print-manager
  ];

  # Audio
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  my.easyeffects = {
    enable = true;
    user = "faupi";
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    disabledPlugins = [ "sap" ];
  };

  # Steamdeck
  my.steamdeck = {
    enable = true;
    opensd = {
      enable = false;  # TODO: Figure out proper config - default is IMO worse than basic Deck config
    };
    steam = {
      enable = true;
      user = "faupi";
    };
  };

  # User 
  programs.dconf.enable = true;
  systemd.services.display-manager.after = [ "home-manager-gdm.service" ];  # Fix for home-manager gdm
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      gdm = {
        home.stateVersion = config.system.stateVersion;
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            text-scaling-factor = 1.25;
          };
          "org/gnome/desktop/a11y/applications" = {
            screen-keyboard-enabled = true;
          };
        };
      };
      faupi = {
        imports = [
          plasma-manager.homeManagerModules.plasma-manager
        ];

        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          spotify
          telegram-desktop
          discord

          git-credential-1password
          freerdp
          libsForQt5.kdepim-runtime
          libsForQt5.kdepim-addons
          libsForQt5.kalendar
          libsForQt5.akonadi
          libsForQt5.akonadi-calendar
          xwaylandvideobridge
          plasmadeck

          headsetcontrol
          protontricks
          wineWowPackages.wayland

          pinta

          yad
          htmlq
          jq

          moonlight-qt
          moonlight-mic-wrapper
        ];

        programs = {
          plasma = {
            enable = true;
            files = {
              # Globals
              kdeglobals = {
                General = {
                  ColorScheme = "BreezeDark";
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
              # Workspace GUI
              kwinrc = {
                Compositing.WindowsBlockCompositing = true;  
                # ^ Was a fix for tearing, but GPU drivers fixed it - games run mega smooth with it on
                Desktops.Rows = 1;
                Tiling.padding = 4;
                Input.TabletMode = "off";  # TODO: Docked mode
                Effect-windowview.BorderActivateAll = 9;  # Disable top-left corner
                
                # Window decorations
                "org\.kde\.kdecoration2" = {
                  ButtonsOnRight = "LIAX";
                  library = "org.kde.breeze";
                  theme = "Breeze";
                };
              };
              kded5rc = {
                Module-device_automounter.autoload = false;
              };
              # Taskbar + start menu
              "plasma-org.kde.plasma.desktop-appletsrc" = {
                "Containments.72.Applets.73.Configuration.General" = {
                  # "Highlight" session buttons
                  systemFavorites = "lock-screen\\,logout\\,save-session\\,switch-user";
                  primaryActions = 1;
                };
                "Containments.72.Applets.75.Configuration.General" = {
                  groupedTaskVisualization = 1;  # Click on group shows previews
                  launchers = "preferred://filemanager,preferred://browser";  # Taskbar items
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
            };
          };
          vscode = {
            enable = true;
            package = pkgs.vscodium-fhs;
            extensions = with pkgs.vscode-extensions; [
              esbenp.prettier-vscode
              bbenoist.nix
              naumovs.color-highlight
              sumneko.lua
              ms-python.python
            ];
            userSettings = {
              "extensions.autoUpdate" = false;
              "editor.fontFamily" = "Consolas, 'Consolas Nerd Font', 'Courier New', monospace";
              "editor.fontLigatures" = true;
              "editor.minimap.renderCharacters" = false;
              "editor.minimap.showSlider" = "always";
              "terminal.integrated.fontFamily" = "CaskaydiaCove NF Mono";
              "terminal.integrated.gpuAcceleration" = "on";
              "workbench.colorTheme" = "Default Dark Modern";
              "workbench.colorCustomizations" = {
                  "statusBar.background" = "#007ACC";
                  "statusBar.foreground" = "#F0F0F0";
                  "statusBar.noFolderBackground" = "#222225";
                  "statusBar.debuggingBackground" = "#511f1f";
              };
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "[json]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
            };
          };
          git = {
            enable = true;
            userName = "Faupi";
            userEmail = "matej.sp583@gmail.com";
          };
          obs-studio = {
            enable = true;
            plugins = with pkgs; [
              obs-studio-plugins.wlrobs
              obs-studio-plugins.obs-pipewire-audio-capture
              obs-studio-plugins.obs-backgroundremoval
            ];
          };
          chromium = {
            # For meetings
            enable = true;
            package = pkgs.ungoogled-chromium;
          };
        };
      };
    };
  };

  # Fonts
  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  # Fix USB problems (usbcore.quirks https://docs.kernel.org/admin-guide/kernel-parameters.html)
  # TODO: Does nothing
  #       - Problem: When booting or waking up with dock attached, USB usually doesn't get initialized (powers on but doesn't communicate)
  boot.extraModprobeConfig = /* modconf */ ''  
    options usbcore quirks=0x28de:0x2001:o
  '';

  system.stateVersion = "23.05";
}
