{ config, pkgs, homeUsers, system, lib, fop-utils, ... }@args:
let
  cfg = {
    # user = "faupi";
    mainInterface = "enp6s0";
    # defaultDisplay = "Virtual-1";
    # defaultAudioSink = "gamestream_virtual.sink";
    # defaultAudioSource = "gamestream_virtual.source";
  };

  inherit (lib) getExe;
  inherit (fop-utils) mkForceRecursively;
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./boot.nix
    ./graphics.nix
    ./hardware.nix
    ./playit.nix
    # ./samba.nix
    # ./sleep.nix
    # ./sunshine.nix
    ./swap.nix
    ./wake-on-lan.nix
  ]);

  flake-configs = {
    ananicy.enable = true;
    avahi.enable = true;
    gaming.enable = true;
    plymouth.enable = true;

    dank-material-shell = {
      enable = true;
      displayManager = {
        enable = true;
        userConfigHome = "/home/faupi";
      };
    };

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

    vr = {
      enable = true;
      autoStart = true;
      # NOTE: Sunshine might not be super happy with the defaults being used *shrug*
      # defaultSink = cfg.defaultAudioSink;
      # defaultSource = cfg.defaultAudioSource;
    };

    nix-ld = {
      enable = true;
      useLibraries = {
        deadZoneRevive = true;
      };
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  users.users.faupi.extraGroups = [ "gamemode" "input" "video" "audio" ];
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { graphical = true; inherit system; }) ];

      programs.dank-material-shell = {
        settings = mkForceRecursively {
          customPowerActionLogout = "";
          lockAtStartup = false;
        };
      };
    };
  };

  programs = {
    kdeconnect.enable = true;

    steam = {
      enable = true;
      extest.enable = false;
      package = pkgs.millennium-steam;

      extraPackages = with pkgs; [
        steamtinkerlaunch
        gamescope
      ];
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    flatpak.enable = true;
    openssh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    r2modman

    (makeAutostartItem rec {
      name = "steam";
      package = makeDesktopItem {
        inherit name;
        desktopName = "Steam";
        exec = "${getExe config.programs.steam.package} -silent %U";
        icon = "steam";
      };
    })
  ];

  system.stateVersion = "25.11";
}
