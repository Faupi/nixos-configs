{ config, pkgs, lib, fop-utils, homeManagerModules, homeUsers, ... }:

# TODO:
#   MODULARIZE THIS FINALLY
#   Rest of KDE setup (localization, whatnot)

let
  script-work-freerdp = pkgs.writeShellScriptBin "run" ''
    op signin
    CRED_CSV=$(/run/wrappers/bin/op item get icn3dn53ifc2ni2uf5xvublcvu --fields label=domain,label=username,label=password,label=local-ip)
    op signout

    CREDS=(''${CRED_CSV//,/ })
    ${pkgs.freerdp}/bin/wlfreerdp +auto-reconnect -clipboard /sound /dynamic-resolution /gfx-h264:avc444 +gfx-progressive /bpp:32 /d:''${CREDS[0]} /u:''${CREDS[1]} /p:''${CREDS[2]} /v:''${CREDS[3]}
  '';
  freerdp-work-remote = pkgs.makeDesktopItem {
    name = "work-remote";
    desktopName = "Remote to work";
    exec = "${script-work-freerdp}/bin/run";
    terminal = false;
    icon = "computer";
    type = "Application";
    categories = [ "Office" ];
  };

  steam-fetch-artwork = pkgs.writeShellScriptBin "steam-fetch-artwork" ''
    ${pkgs.coreutils}/bin/yes "" | ${pkgs.steamgrid}/bin/steamgrid -steamdir ~/.steam/steam -nonsteamonly -onlymissingartwork -steamgriddb "$(<${config.sops.secrets.steamgrid-api-key.path})"
  '';
in {
  imports = [ ./boot.nix ./hardware.nix ./external-display.nix ./audio.nix ];

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
      opensd = {
        # TODO: Figure out proper config - default is IMO worse than basic Deck config
        enable = false;
      };
      gamescope = {
        enable = true;
        user = "faupi";
        desktopSession = "plasmawayland";
        # TODO: Switch to "plasma" for non-docked mode - fixes Steam input mapping for desktop use
        remotePlay.openFirewall = true;
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
    users = {
      faupi = rec {
        imports = [ homeUsers.faupi ];

        home.packages = with pkgs; [
          # Socials and chill
          (spotify.overrideAttrs (OldAttrs: { deviceScaleFactor = 1; }))
          telegram-desktop
          discord

          # Gaming
          steam-fetch-artwork
          protontricks
          wineWowPackages.wayland
          grapejuice # Roblox
          libstrangle # Frame limiter

          # Game-streaming
          moonlight-qt

          krita
          mpv
          freerdp-work-remote
        ];

        programs = rec {
          obs-studio = {
            enable = true;
            plugins = with pkgs; [
              obs-studio-plugins.wlrobs
              obs-studio-plugins.obs-pipewire-audio-capture
              obs-studio-plugins.obs-backgroundremoval
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
                  hiddenItems =
                    "org.kde.kalendar.contact,org.kde.plasma.clipboard,org.kde.kscreen";
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

  # ZSH completion link
  environment.pathsToLink = [ "/share/zsh" ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Wayland support for Electron and Chromium apps
  };

  # Fonts
  fonts.fonts = with pkgs; [ nerdfonts ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  # Autoload
  boot.kernelModules = [ "v4l2-loopback" ];

  system.stateVersion = "23.05";
}
