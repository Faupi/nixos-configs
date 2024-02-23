{ config, pkgs, lib, fop-utils, homeUsers, ... }:
let
  steam-fetch-artwork = pkgs.writeShellScriptBin "steam-fetch-artwork" ''
    ${pkgs.coreutils}/bin/yes "" | ${lib.getExe pkgs.steamgrid} -steamdir ~/.steam/steam -nonsteamonly -onlymissingartwork -steamgriddb "$(<${config.sops.secrets.steamgrid-api-key.path})"
  '';

  moonlight-mic-wrapper-script = pkgs.writeShellScript "moonlight-mic-wrapper" ''
    trap 'kill %1' SIGINT
    pw-cli -m load-module libpipewire-module-vban-send local.ifname="enp4s0f3u1u4c2" destination.ip="$(${lib.getExe pkgs.dig} +short faupi-pc.local)" destination.port=6980 sess.name="Deck" sess.media="audio" & 
    ${lib.getExe pkgs.moonlight-qt}
  '';

  moonlight-mic-wrapper = pkgs.makeDesktopItem {
    name = "com.moonlight_stream.Moonlight-Mic";
    comment = "Stream games from your NVIDIA GameStream-enabled PC";
    desktopName = "Moonlight (with mic)";
    exec = toString moonlight-mic-wrapper-script;
    terminal = false;
    icon = "moonlight";
    type = "Application";
    categories = [ "Qt" "Game" ];
    keywords = [ "nvidia" "gamestream" "stream" ];
  };
in
{
  imports = [ ./hardware.nix ./audio.nix ./external-display ];

  services.openssh.enable = true;

  networking.networkmanager.enable = true;

  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  my = {
    plasma = { enable = true; };
    steamdeck = {
      enable = true;
      gamescope = {
        enable = true;
        user = "faupi";
        desktopSession = "plasmawayland";
      };
    };
    vintagestory = {
      client = {
        enable = true;
        user = "faupi";
      };
      mods.enable = true;
    };
  };

  programs.dconf.enable = true; # Needed for EasyEffects and similar

  environment.systemPackages = with pkgs;
    [
      waypipe # Cura remoting
    ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    disabledPlugins = [ "sap" ];
  };

  # User 
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # Automatically resolve exsting files to backup

    users = {
      faupi = {
        imports = [ homeUsers.faupi ];

        home.packages = with pkgs; [
          # Gaming
          steam-fetch-artwork
          protontricks
          wineWowPackages.wayland
          grapejuice # Roblox
          unstable.libstrangle # Frame limiter

          # Game-streaming
          moonlight-qt
          moonlight-mic-wrapper

          krita
          mpv
        ];

        programs = {
          obs-studio = {
            enable = true;
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-pipewire-audio-capture
              obs-vkcapture
              obs-vaapi
            ];
          };

          plasma = {
            configFile = {
              # Applets customization
              "plasma-org.kde.plasma.desktop-appletsrc" = {
                # TODO: These containment IDs change - needs some INI filtering on install..
                # Actually maybe straight up just replace this one with a saved INI here.
                # Containments.3.Applets.4 plugin=org.kde.plasma.kickoff
                "Containments.3.Applets.4.Configuration.General" = {
                  # "Highlight" session buttons
                  systemFavorites = "lock-screen\\,logout\\,save-session";
                  primaryActions = 1;
                };
                # Containments.3.Applets.6 plugin=org.kde.plasma.icontasks
                "Containments.3.Applets.6.Configuration.General" = {
                  groupedTaskVisualization = 1; # Click on group shows previews
                  launchers =
                    "preferred://filemanager,preferred://browser"; # Taskbar items
                };
                # Digital Clock
                # Containments.3.Applets.19 plugin=org.kde.plasma.digitalclock
                "Containments.3.Applets.19.Configuration.Appearance" = {
                  use24hFormat = 2; # Force 24h format specifically
                  dateFormat = "isoDate"; # ISO date - 2023-08-23
                };
                # Task indicators
                # Containments.9 plugin=org.kde.plasma.private.systemtray
                "Containments.9.General" = {
                  hiddenItems = pkgs.lib.concatStringsSep "," [
                    "org.kde.kalendar.contact"
                    "org.kde.plasma.clipboard"
                    "org.kde.kscreen"
                    "Discover Notifier_org.kde.DiscoverNotifier"
                  ];
                };
              };

              plasmashellrc = {
                "PlasmaViews.Panel 72.Defaults".thickness = 46; # Taskbar height
              };
            };
          };
        };
      };
    };
  };

  # Add wrappers for 1Password
  programs._1password-gui = {
    enable = true;
    package = config.home-manager.users.faupi.programs._1password.package;
  };

  # ZSH completion link
  environment.pathsToLink = [ "/share/zsh" ];

  networking.firewall = fop-utils.recursiveMerge [
    # KDE Connect
    {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    }

    # Gamestreaming mic passthrough RTP 
    {
      allowedUDPPorts = [ 25000 ];
    }
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Autoload
  boot.kernelModules = [ "v4l2-loopback" ];

  system.stateVersion = "23.05";
}
