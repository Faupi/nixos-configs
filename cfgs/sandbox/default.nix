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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [ 
    pkgs.gnome.cheese
    pkgs.gnome-photos
    pkgs.gnome.gnome-music
    # pkgs.gnome.gnome-terminal
    # pkgs.gnome.gedit
    pkgs.epiphany  # Web
    # pkgs.evince
    pkgs.gnome.gnome-characters
    # pkgs.gnome.totem
    pkgs.gnome.tali
    pkgs.gnome.iagno
    pkgs.gnome.hitori
    pkgs.gnome.atomix
    pkgs.gnome-tour
    pkgs.gnome.gnome-maps
    pkgs.gnome.gnome-keyring
    pkgs.gnome.geary
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
