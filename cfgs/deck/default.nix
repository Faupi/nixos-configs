{ config, pkgs, lib, ... }:

let

  # Fetch the "development" branch of the Jovian-NixOS repository
  jovian-nixos = builtins.fetchTarball {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/8a934c6ebf10d0a153f0b62d933f7946e67f610f.tar.gz";
    sha256 = "sha256:0f06vjsfppjwk4m94ma1wqakfc7fdl206db39n1hsiwp43qz7r7x";
  };

  # Gamescope switching
  gdmSetSessionScript = pkgs.writeScriptBin "set-session" ''
    #! ${pkgs.bash}/bin/sh
    /run/current-system/sw/bin/sed -i -e "s|^Session=.*|Session=$1|" /var/lib/AccountsService/users/faupi
    exit 0
  '';
  desktopSessionScript = pkgs.writeScriptBin "desktop-switch" ''
    #! ${pkgs.bash}/bin/sh
    /run/wrappers/bin/sudo ${gdmSetSessionScript}/bin/set-session plasma
    exit 0
  '';
  gamescopeSessionScript = pkgs.writeScriptBin "gamescope-switch" ''
    #! ${pkgs.bash}/bin/sh
    /run/wrappers/bin/sudo ${gdmSetSessionScript}/bin/set-session steam-wayland
    /run/current-system/sw/bin/qdbus org.kde.Shutdown /Shutdown logout
    exit 0
  '';
  steam-gamescope-switcher = pkgs.makeDesktopItem {
    name = "steam-gaming-mode";
    desktopName = "Switch to Gaming Mode";
    exec = "${gamescopeSessionScript}/bin/gamescope-switch";
    terminal = false;
    icon = "steam";
    type = "Application";
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
        wayland = false;
        autoLogin.delay = 5;
      };
      autoLogin = {
        enable = true;
        user = "faupi";
      };
      defaultSession = "plasma";
    };
    excludePackages = [ 
      pkgs.xterm
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];  # Fix shit for Deck

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

  # Audio
  programs.dconf.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;  # We don't want pulseaudio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    jupiter-dock-updater-bin
    steamdeck-firmware
  ];

  # Workaround for GDM autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
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
      faupi = {
        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          steam
          steam-gamescope-switcher
          protonup
          lutris
        ];
      };
    };
  };

  # Gamescope-switcher hook
  environment.etc = {
    # Set target session to desktop after every login
    "gdm/PreSession/Default".source = "${desktopSessionScript}/bin/desktop-switch";
  };

  security.sudo.extraRules = [
    {
      users = [ "faupi" "gdm" ];
      commands = [
        {
          command = "${gdmSetSessionScript}/bin/set-session *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Testing KDE dm
  services.xserver.desktopManager.plasma5.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
  ];
  # Fix for KDE
  programs.ssh.askPassword = lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  system.stateVersion = "23.05";
}
