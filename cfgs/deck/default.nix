{ config, pkgs, lib, inputs, ... }:

let
  jovian = builtins.fetchTarball {
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
  imports = [ 
    "${jovian}/modules"
    ./boot.nix
    ./hardware.nix
  ]; 

  networking.hostName = "deck";
  networking.networkmanager.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  services.openssh.enable = true;  # TODO: Remove when installed

  # Display
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
  # Workaround for GDM autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Desktop
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
  # Fix
  # programs.ssh.askPassword = lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;  # We don't want pulseaudio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    jupiter-dock-updater-bin
  ];

  # User 
  programs.dconf.enable = true;
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
        imports = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];

        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          steam
          steam-gamescope-switcher
          protonup
          lutris
        ];

        programs = {
          plasma = {
            enable = true;
            files = {
              "baloofilerc"."General"."dbVersion" = 2;
              "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.venv,venv,core-dumps,lost+found";
              "baloofilerc"."General"."exclude filters version" = 8;
              "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
              "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
              "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = true;
              "kded5rc"."Module-device_automounter"."autoload" = false;
              "kdeglobals"."KDE"."widgetStyle" = "Breeze";
              "kdeglobals"."KScreen"."ScaleFactor" = 1.25;
              "kdeglobals"."KScreen"."ScreenScaleFactors" = "eDP=1.25;DisplayPort-0=1;";
              "khotkeysrc"."Gestures"."Disabled" = true;
              "khotkeysrc"."Gestures"."MouseButton" = 2;
              "khotkeysrc"."Gestures"."Timeout" = 300;
              "kwinrc"."Compositing"."WindowsBlockCompositing" = false;
              "kwinrc"."Desktops"."Rows" = 1;
              "kwinrc"."Tiling"."padding" = 4;
              "kwinrc"."Xwayland"."Scale" = 1.75;
              "plasma-localerc"."Formats"."LANG" = "en_DK.UTF-8";
              "plasmarc"."Theme"."name" = "breeze-dark";
            };
          };
          _1password-gui.enable = true;
        };
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

  system.stateVersion = "23.05";
}
