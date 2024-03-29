{ config, pkgs, lib, ... }:
let
  mkGnomeExtension = package: extensionConfig: {
    # Creates needed definitions for a gnome package to be used under a home-manager user
    home.packages = [ package ];
    dconf.settings = {
      "org/gnome/shell".enabled-extensions = [ package.extensionUuid ];
      "org/gnome/shell/extensions/${package.extensionPortalSlug}" =
        extensionConfig;
    };
  };
in
{
  # X11 server
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
  };

  # GNOME
  programs.dconf.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [
    pkgs.epiphany # Web
    # pkgs.evince             # PDF viewer
    pkgs.gnome.atomix # Game
    pkgs.gnome.cheese # Camera
    pkgs.gnome.geary # Email
    pkgs.gnome.gedit # Text editor
    pkgs.gnome.hitori # Game
    pkgs.gnome.iagno # Game
    pkgs.gnome.tali # Game
    pkgs.gnome.yelp # Help viewer
    # pkgs.gnome.totem        # Videos
    pkgs.gnome.simple-scan # Doc scanner
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
  ];

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "faupi";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User 
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.faupi = with pkgs;
      lib.mkMerge [
        {
          home.username = "faupi";
          home.homeDirectory = "/home/faupi";
          home.stateVersion = config.system.stateVersion;

          dconf.settings = {
            "org/gnome/shell" = {
              disable-user-extensions = false;

              favorite-apps = [ "firefox.desktop" ];
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              enable-hot-corners = false;
            };
            "org/gnome/desktop/background" = {
              picture-uri =
                "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
              picture-uri-dark =
                "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
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
          panel-positions = ''{"0":"BOTTOM"}'';
          panel-sizes = ''{"0":45}'';
          panel-lengths = ''{"0":100}'';
          panel-element-positions = ''
            {"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'';
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
          hot-sensors =
            [ "_processor_usage_" "_memory_usage_" "__network-rx_max__" ];
          position-in-panel = 0;
          update-time = 5;
        })
        (mkGnomeExtension gnomeExtensions.user-themes { })
        (mkGnomeExtension gnomeExtensions.pano {
          # Clipboard manager
          show-indicator = false;
        })
      ];
  };
}
