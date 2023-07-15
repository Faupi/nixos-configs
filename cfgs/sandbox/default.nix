{ config, pkgs, lib, ... }: {
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
    gnome.gnome-browser-connector
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-panel
    gnomeExtensions.vitals
    gnomeExtensions.user-themes
  ];

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

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "faupi";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # User packages
  users.users.faupi.packages = with pkgs; [
    
  ];

  system.stateVersion = "22.11";
}
