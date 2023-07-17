{ config, pkgs, lib, ... }:

let

  # Fetch the "development" branch of the Jovian-NixOS repository
  jovian-nixos = builtins.fetchTarball {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/8a934c6ebf10d0a153f0b62d933f7946e67f610f.tar.gz";
    sha256 = "sha256:0f06vjsfppjwk4m94ma1wqakfc7fdl206db39n1hsiwp43qz7r7x";
  };

  mkGnomeExtension = package: extensionConfig: {
    # Creates needed definitions for a gnome package to be used under a home-manager user
    home.packages = [package];
    dconf.settings = {
      "org/gnome/shell".enabled-extensions = [package.extensionUuid];
      "org/gnome/shell/extensions/${package.extensionPortalSlug}" = extensionConfig;
    };
  };

  # Gamescope
  gamescope-switcher = pkgs.writeShellScriptBin "gamescope-switcher" ''
    set-session () {
      mkdir -p ~/.local/state
      >~/.local/state/steamos-session-select echo "$1"
    }
    consume-session () {
      if [[ -e ~/.local/state/steamos-session-select ]]; then
        cat ~/.local/state/steamos-session-select
        rm ~/.local/state/steamos-session-select
      else
        echo "gamescope"
      fi
    }
      session=$(consume-session)
      case "$session" in
        plasma)
          exec gnome-shell --display-server --wayland
          ;;
        gamescope)
          exec steam-session
          ;;
      esac
  '';

  gamescope-switcher-session-desktop = (pkgs.writeTextFile {
    name = "gamescope-switcher-session";
    destination = "/share/wayland-sessions/gamescope-switcher-session.desktop";
    text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Name=Gaming Mode (With GNOME)
      Exec=${gamescope-switcher}/bin/gamescope-switcher
      Icon=steamicon.png
      Type=Application
      DesktopNames=gamescope-switcher-session
    '';
  }) // {
    providedSessions = [ "gamescope-switcher-session" ];
  };

in 
{
  # Import jovian modules
  imports = [ 
    ./boot.nix
    ./hardware.nix
    "${jovian-nixos}/modules" 
  ]; 
  
  services.openssh.enable = true;  # TODO: Remove when installed

  networking.hostName = "deck";

  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
      defaultSession = "steam-wayland";
      sessionPackages = [ gamescope-switcher-session-desktop ];
      autoLogin = {
        enable = true;
        user = "faupi";
      };
    };
    excludePackages = [ 
      pkgs.xterm
    ];
  };

  # Jovian Steam
  jovian = {
    steam = {
      enable = true;
    };
    devices.steamdeck = {
      enable = true;
      enableSoundSupport = true;
    };
  };

  # Enable GNOME
  programs.dconf.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [ 
    pkgs.epiphany             # Web
    # pkgs.evince             # PDF viewer
    pkgs.gnome.atomix         # Game
    pkgs.gnome.cheese         # Camera
    pkgs.gnome.geary          # Email
    pkgs.gnome.gedit          # Text editor
    pkgs.gnome.hitori         # Game
    pkgs.gnome.iagno          # Game
    pkgs.gnome.tali           # Game
    pkgs.gnome.yelp           # Help viewer
    # pkgs.gnome.totem        # Videos
    pkgs.gnome.simple-scan    # Doc scanner
    pkgs.gnome.gnome-contacts
    pkgs.gnome.gnome-calendar
    pkgs.gnome.gnome-characters
    pkgs.gnome.gnome-maps
    pkgs.gnome.gnome-music
    # pkgs.gnome.gnome-terminal
    pkgs.gnome.gnome-weather
    # No `gnome` path in name
    pkgs.gnome-text-editor
    pkgs.gnome-tour
    pkgs.gnome-photos
  ];
  environment.systemPackages = with pkgs; [ 
    gnome-browser-connector
    gnome.gnome-tweaks

    jupiter-dock-updater-bin
    steamdeck-firmware

    gamescope-switcher-session
  ];

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # User 
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      faupi = with pkgs; lib.mkMerge [
        {
          home.username = "faupi";
          home.homeDirectory = "/home/faupi";
          home.stateVersion = config.system.stateVersion;

          home.packages = [
            steam-rom-manager
            steam
            protonup
            lutris
          ];

          dconf.settings = {
            "org/gnome/shell" = {
              disable-user-extensions = false;

              favorite-apps = [
                "firefox.desktop"
              ];
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              enable-hot-corners = false;
            };
            "org/gnome/desktop/background" = {
              picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
              picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
            };
            "org/gnome/desktop/a11y/applications" = {
              screen-keyboard-enabled = true;
              large-text-enabled = true;
            };
          };
        }
        (mkGnomeExtension gnomeExtensions.openweather {
          delay-ext-int = 5;
          refresh-interval-current = 300;
          unit = "celsius";
          wind-speed-unit = "kph";
          pressure-unit = "kPa";
          position-in-panel = "left";
          show-text-in-panel = true;
          menu-alignment = 0.0;
          city = "49.22574, 17.663>Zlín>0";
        })
        (mkGnomeExtension gnomeExtensions.dash-to-panel {
          panel-positions = "{\"0\":\"BOTTOM\"}";
          panel-sizes = "{\"0\":45}";
          panel-lengths = "{\"0\":100}";
          panel-element-positions = "{\"0\":[{\"element\":\"showAppsButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"activitiesButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"leftBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"centerBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"taskbar\",\"visible\":true,\"position\":\"centerMonitor\"},{\"element\":\"rightBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"dateMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"systemMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"desktopButton\",\"visible\":true,\"position\":\"stackedBR\"}]}";
          appicon-margin = 2;
          appicon-padding = 6;
          dot-style-focused = "METRO";
          dot-style-unfocused = "DASHES";
          trans-use-custom-bg = false;
          trans-use-custom-opacity = true;
          trans-panel-opacity = 0.6;
          trans-use-dynamic-opacity = false;
          show-favories = true;
          show-running-apps = true;
          tray-padding = 2;
        })
        (mkGnomeExtension gnomeExtensions.vitals {
          hot-sensors = ["_processor_usage_" "_memory_usage_" "__network-rx_max__"];
          position-in-panel = 0;
          update-time = 5;
        })
        (mkGnomeExtension gnomeExtensions.user-themes {})
        (mkGnomeExtension gnomeExtensions.pano {
          # Clipboard manager
          show-indicator = false;
        })
        (mkGnomeExtension gnomeExtensions.arcmenu {
          position-in-panel = "Left";
          show-activities-button = false;
          enable-menu-hotkey = true;
          menu-hotkey-type = "Super_L";
          hide-overview-on-startup = true;
          menu-layout = "Default";
          override-menu-theme = true;
          menu-border-radius = 5;
          dash-to-panel-standalone = false;
          button-padding = 5;  # Adds proper padding
          menu-button-position-offset = 0;
          custom-menu-button-icon-size = 24;
        })
        (mkGnomeExtension gnomeExtensions.hide-universal-access {})
      ];
    };
  };

  system.stateVersion = "23.05";
}
