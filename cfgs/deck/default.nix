{ config, pkgs, lib, plasma-manager, ... }:

# TODO:
#   Rest of KDE setup (localization, whatnot)
#   oh-my-posh
#   Discord
#   Audio enhancements (mic boost + noise cancellation VST)

let 
  startMoonlight = pkgs.writeShellScriptBin "start-moonlight" ''
    trap "kill %1" SIGINT SIGCHLD
    ${pkgs.ffmpeg}/bin/ffmpeg -ac 1 -f pulse -i default -acodec mp2 -ac 1 -f rtp rtp://192.168.88.254:25000 & moonlight
    exit 0
  '';
  moonlight-mic-wrapper = pkgs.makeDesktopItem {
    name = "com.moonlight_stream.Moonlight_microphone";
    comment = "Stream games from your NVIDIA GameStream-enabled PC";
    desktopName = "Moonlight (with mic)";
    exec = "${startMoonlight}/bin/start-moonlight";
    terminal = false;
    icon = "moonlight";
    type = "Application";
    categories = [ "Qt" "Game" ];
    keywords = [ "nvidia" "gamestream" "stream" ];
  };

  # https-handler-script = pkgs.writeShellScriptBin "https-open" ''
  #   if [[ "$1" == "https://teams.microsoft.com/"* ]]; then
  #     chromium --app="$1"
  #   else
  #     xdg-open "$1" # Just open with the default handler
  #   fi
  # '';
  # https-handler = pkgs.makeDesktopItem {
  #   name = "https-handler";
  #   desktopName = "HTTP Scheme Handler";
  #   exec = "${https-handler-script}/bin/https-open %u";
  #   type = "Application";
  #   mimeTypes = [ "x-scheme-handler/https" ];
  #   startupNotify = false;
  # };

  start-freerdp-work-remote = pkgs.writeShellScriptBin "run" ''
    CSV=$(/run/wrappers/bin/op item get icn3dn53ifc2ni2uf5xvublcvu --fields label=domain,label=username,label=password,label=local-ip)
    creds=(''${CSV//,/ })
    ${pkgs.freerdp}/bin/wlfreerdp +auto-reconnect -clipboard /sound /dynamic-resolution /gfx-h264:avc444 +gfx-progressive /bpp:32 /d:''${creds[0]} /u:''${creds[1]} /p:''${creds[2]} /v:''${creds[3]}
  '';
  freerdp-work-remote = pkgs.makeDesktopItem {
    name = "work-remote";
    desktopName = "Remote to work";
    exec = "${start-freerdp-work-remote}/bin/run";
    terminal = false;
    icon = "computer";
    type = "Application";
    categories = [ "Office" ];
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
      desktopSession = "plasmawayland";
    };
  };

  # User 
  programs.dconf.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      faupi = {
        imports = [
          plasma-manager.homeManagerModules.plasma-manager
        ];

        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          # Socials and chill
          spotify
          telegram-desktop
          discord
          xwaylandvideobridge

          # Calendar integration
          libsForQt5.kdepim-runtime
          libsForQt5.kdepim-addons
          libsForQt5.kalendar
          libsForQt5.akonadi
          libsForQt5.akonadi-calendar

          # Gaming
          protontricks
          wineWowPackages.wayland

          # Utils
          htmlq
          jq
          # https-handler

          # Game-streaming
          moonlight-qt
          moonlight-mic-wrapper

          pinta  # Paint.NET alternative
          plasmadeck
          freerdp-work-remote
        ];

        programs = {
          plasma = {
            enable = true;
            configFile = {
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
