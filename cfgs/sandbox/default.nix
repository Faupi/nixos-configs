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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  programs.firefox = {
    package = pkgs.firefox-wayland;
    enable = true;
    policies = {
      DisablePocket = true;
      DisableTelemetry = true;
      SearchEngines.Default = "DuckDuckGo";
      SearchEngines.PreventInstalls = true;
      ExtensionSettings = {
        "sponsorBlocker@ajay.app" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorBlocker@ajay.app/latest.xpi";
        };
      };
    };
    preferences = {
      app.normandy.first_run = false;
      extensions.activeThemeID = "firefox-compact-dark@mozilla.org";
    };
  };

  system.stateVersion = "22.11";
}
