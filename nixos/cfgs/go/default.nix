{ homeUsers, pkgs, lib, fop-utils, ... }:
{
  imports = [
    ./boot.nix
    ./early-oom.nix
    ./hardware
    ./steam
    ./suspend.nix
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
    plasma6.enable = true;
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

      flake-configs = {
        plasma.virtualKeyboard.enable = true;
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

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    cemu
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

    inputplumber = {
      enable = true;
      package = pkgs.inputplumber-patched;
    };
    dbus.packages = [ pkgs.inputplumber-patched ]; # https://github.com/NixOS/nixpkgs/pull/463014
  };

  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";
}
