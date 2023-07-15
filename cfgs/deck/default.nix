{ config, pkgs, lib, ... }:

let

  # Fetch the "development" branch of the Jovian-NixOS repository
  jovian-nixos = builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  };

in {
  # Import jovian modules
  imports = [ 
    ./boot.nix
    # ./hardware.nix  # TODO: Send over from Deck before install
    "${jovian-nixos}/modules" 
  ]; 

  jovian = {
    steam.enable = true;
    devices.steamdeck = {
      enable = true;
      enableSoundSupport = false;  # TODO: fix
    };
  };

  networking.hostName = "deck";

  services.xserver.displayManager.gdm.wayland = lib.mkForce true; # lib.mkForce is only required on my setup because I'm using some other NixOS configs that conflict with this value
  services.xserver.displayManager.defaultSession = "steam-wayland";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "faupi";

  # Enable GNOME
  sound.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

  systemd.services.gamescope-switcher = {
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      User = 1000;
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };

    script = ''
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
      while :; do
        session=$(consume-session)
        case "$session" in
          plasma)
            dbus-run-session -- gnome-shell --display-server --wayland
            ;;
          gamescope)
            steam-session
            ;;
        esac
      done
    '';
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
    jupiter-dock-updater-bin
    steamdeck-firmware
  ];

  system.stateVersion = "23.05";
}