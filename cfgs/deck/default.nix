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

  gamescopeScript = pkgs.writeScriptBin "gamescope-switch" ''
    #! ${pkgs.bash}/bin/sh
    exec /etc/gdm/set-session.sh faupi steam-wayland
    gnome-session-quit --logout
  '';

  steam-gamescope-switcher = pkgs.makeDesktopItem {
    name = "steam-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    exec = "${gamescopeScript}/bin/vpn";
    terminal = false;
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
        autoLogin.delay = 15;
      };
      autoLogin = {
        enable = true;
        user = "faupi";
      };
      defaultSession = "gnome";
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
  ];

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # User 
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
      faupi = with pkgs; lib.mkMerge [
        {
          home.username = "faupi";
          home.homeDirectory = "/home/faupi";
          home.stateVersion = config.system.stateVersion;

          home.packages = [
            steam-rom-manager
            steam
            steam-gamescope-switcher
            gnome.gnome-session  # Needed for switcher shortcut
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
              text-scaling-factor = 1.25;
            };
            "org/gnome/desktop/a11y/applications" = {
              screen-keyboard-enabled = true;
            };
            "org/gnome/desktop/background" = {
              picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
              picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
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

  # TODO: Rework to switch GDM's last/preferred/default session in /var/lib/AccountsService/users/<USER> on login
  #       - https://brokkr.net/2016/10/27/setting-default-user-session-in-gdm-default-latest/
  #       gdm/PostSession - Set to desktop
  #       gdm/Init(?) - Set to whatever default
  #         - NOTE: Init could be also whenever the GUI loads, anything at boot would work though
  #       GNOME app   - Set to GameScope

  # Gamescope-switcher
  environment.etc = {
    # GDM session setter - args: username, session name
    "gdm/set-session.sh".text = ''
      #!/bin/sh
      sed -i "" -e "s|^Session=.*|Session=$2|" /var/lib/AccountsService/users/$1
      exit 0
    '';
    "gmd/PostSession/Default".text = ''
      exec /etc/gdm/set-session.sh faupi gnome
    '';
  };

  # security.sudo.extraRules = [
  #   {
  #     users = [ "faupi" ]; 
  #     commands = [
  #       {
  #         command = "/nix/var/nix/profiles/system/specialisation/desktop/bin/switch-to-configuration switch";
  #         options = [ "NOPASSWD" ];
  #       }
  #       {
  #         command = "/nix/var/nix/profiles/system/specialisation/gamescope/bin/switch-to-configuration switch";
  #         options = [ "NOPASSWD" ];
  #       }
  #     ];
  #   }
  # ];

  system.stateVersion = "23.05";
}
