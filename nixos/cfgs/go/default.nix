{ homeUsers, pkgs, lib, fop-utils, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./boot.nix
    ./early-oom.nix
    ./hardware
    ./sleep
    ./steam
    ./swap.nix
    ./vr
  ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  flake-configs = {
    dank-material-shell.enable = true;
    plymouth.enable = true;

    audio = {
      enable = true;
      user = "faupi";
    };

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autoStart = true;
      useSSHAgent = true;
    };

    monitor-input-switcher = {
      enable = false;
      user = "faupi";
    };
  };

  # User 
  users.users.faupi.extraGroups = [ "gamemode" "input" ];
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; }) ];

      programs.dank-material-shell = {
        settings = {
          customPowerActionLogout = mkForce "steamosctl switch-to-game-mode";
        };
      };

      programs.plasma = {
        powerdevil = {
          AC.powerProfile = "performance"; # Switching to Custom profile with command below

          batteryLevels.lowLevel = 20; # Small battery, 20% might also be a FW low battery alarm
          lowBattery.powerButtonAction = "hibernate";
        };

        configFile = {
          powerdevilrc = {
            # TODO: Switch to powerdevil options once https://github.com/nix-community/plasma-manager/pull/384 is merged
            "AC/RunScript".ProfileLoadCommand = lib.getExe (pkgs.writeShellApplication {
              name = "custom-performace-profile";
              runtimeInputs = with pkgs; [ coreutils ];
              text = /*sh*/''
                steamosctl set-performance-profile custom && \
                steamosctl set-tdp-limit 30
              '';
            });
          };
        };
      };
    };
  };

  # FOR TEAMSPEAK
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    ukmm
    (fop-utils.wrapPkgBinary {
      inherit pkgs;
      package = pkgs.suyu;
      nameAffix = "amd";
      variables = {
        QT_QPA_PLATFORM = "xcb";
        AMD_VULKAN_ICD = "RADV";
      };
    })
    (fop-utils.wrapPkgBinary {
      inherit pkgs;
      package = pkgs.bleeding.teamspeak6-client;
      nameAffix = "clean";
      arguments = [
        "--disable-audio-processing"
        "--disable-features=WebRtcEchoCanceller3,ChromeWideEchoCancellation,WebRtcAllowInputVolumeAdjustment"
        "--enable-features=WebRtcPipeWireCapturer"
      ];
    })
  ];

  programs = {
    kdeconnect.enable = true;
    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    flatpak.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
  };

  systemd.user.services.ppd-steamos-bridge = {
    description = "Map PPD performance profile to SteamOS custom profile";
    after = [
      "graphical-session.target"
      "steamos-manager.service"
    ];
    wants = [ "steamos-manager.service" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "ppd-steamos-bridge";
        runtimeInputs = with pkgs; [
          coreutils
          glib
          power-profiles-daemon
          steamos-manager
        ];
        text = /*sh*/''
          set -euo pipefail

          apply_profile() {
            local profile
            profile="$(powerprofilesctl get 2>/dev/null || true)"
            if [ "$profile" = "performance" ]; then
              steamosctl set-performance-profile custom
              steamosctl set-tdp-limit 30
            fi
          }

          apply_profile

          gdbus monitor --system \
            --dest net.hadess.PowerProfiles \
            --object-path /net/hadess/PowerProfiles | while read -r line; do
            case "$line" in
              *PropertiesChanged*)
                apply_profile
                ;;
            esac
          done
        '';
      });
    };
  };

  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";
}
