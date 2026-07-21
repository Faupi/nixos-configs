{ pkgs, homeUsers, system, lib, ... }@args:
let
  cfg = {
    # user = "faupi";
    mainInterface = "enp6s0";
    # defaultDisplay = "Virtual-1";
    # defaultAudioSink = "gamestream_virtual.sink";
    # defaultAudioSource = "gamestream_virtual.source";
  };
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./boot.nix
    ./graphics.nix
    ./hardware.nix
    # ./playit.nix
    # ./samba.nix
    # ./sleep.nix
    # ./sunshine.nix
    ./swap.nix
    ./wake-on-lan.nix
  ]);

  flake-configs = {
    ananicy.enable = true;
    avahi.enable = true;
    dank-material-shell.enable = true;
    gaming.enable = true;
    plymouth.enable = true;

    _1password = {
      enable = true;
      users = [ "faupi" ];
      autoStart = true;
      useSSHAgent = true;
    };

    audio = {
      enable = true;
      user = "faupi";
    };

    vr = {
      enable = true;
      autoStart = true;
      # NOTE: Sunshine might not be super happy with the defaults being used *shrug*
      # defaultSink = cfg.defaultAudioSink;
      # defaultSource = cfg.defaultAudioSource;
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
    };
  };

  programs = {
    steam = {
      enable = true;
      extest.enable = false;
      package = pkgs.steam;

      extraPackages = with pkgs; [
        steamtinkerlaunch
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

    greetd = {
      enable = true;

      settings = {
        default_session = {
          user = "greeter";
          command = "${lib.getExe pkgs.tuigreet} --remember --remember-user-session";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    r2modman

    (makeAutostartItem rec {
      name = "steam";
      package = makeDesktopItem {
        inherit name;
        desktopName = "Steam";
        exec = "steam -silent %U";
        icon = "steam";
      };
    })
  ];

  system.stateVersion = "25.11";
}
