{ config, pkgs, lib, ... }: 
let 
mkGnomeExtension = package: args: {
  # Creates a gnome extension definition and sets its config if supplied
  home.packages = [package];
  dconf.settings."org/gnome/shell".enabled-extensions = [package.extensionUuid];
  dconf.settings."org/gnome/shell/extensions/${package.extensionPortalSlug}" = args;
};
in
{
  imports = [
    ./boot.nix
    ./hardware.nix
  ];

  networking.hostName = "sandbox";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  # X11 server
  services.xserver.enable = true;
  services.xserver.excludePackages = [ 
    pkgs.xterm
  ];

  # GNOME
  # TODO: Move GNOME configs to home manager + add custom configurations there
  programs.dconf.enable = true;
  services.xserver.displayManager.gdm.enable = true;
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
    users.faupi = lib.mkMerge [
      {
        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          gnomeExtensions.vitals
          gnomeExtensions.user-themes
          gnomeExtensions.pano
        ];

        dconf.settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;

            # `gnome-extensions list` for a list
            enabled-extensions = [
              "Vitals@CoreCoding.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "pano@ethan.io"
            ];

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
          "org/gnome/shell/extensions/pano" = {
            show-indicator = false;
          };
        };
      }
      mkGnomeExtension pkgs.gnomeExtensions.openweather {
        delay-ext-int = 5;
        refresh-interval-current = 300;
        unit = "celsius";
        wind-speed-unit = "kph";
        pressure-unit = "kPa";
        position-in-panel = "left";
        show-text-in-panel = true;
        menu-alignment = 0.0;
        city = "49.22574, 17.663>Zlin>0";
      }
      mkGnomeExtension pkgs.gnomeExtensions.dash-to-panel
    ];
  };

  system.stateVersion = "22.11";
}
