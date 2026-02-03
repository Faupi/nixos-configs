{ homeUsers, pkgs, fop-utils, ... }:
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
      home.packages = with pkgs; [
        openttd-jgrpp
      ];
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
    inputplumber.enable = true;
    power-profiles-daemon.enable = true;
  };

  networking.networkmanager.enable = true;

  system.stateVersion = "23.11";
}
