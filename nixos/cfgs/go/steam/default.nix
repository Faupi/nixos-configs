{ config, pkgs, lib, ... }:
with lib;
let

  steamBase = pkgs.steam;

  steamSharedOverride = (old: {
    extraBwrapArgs = [
      # Mount the decky themes directory under the user so it can be served under the same host
      "--ro-bind ${config.jovian.decky-loader.stateDir}/themes $HOME/.local/share/Steam/steamui/themes_custom"
    ];

    # Scope some environment variables for whole Steam so that for example MoonDeck knows where to look for things
    extraEnv = {
      DECKY_HOME = config.jovian.decky-loader.stateDir;
    };
  });

  steamConfig = {
    gamescope = steamBase.override (old: (steamSharedOverride old) // {
      extraProfile =
        let
          gamescopeDummy = pkgs.writeScriptBin "gamescope" (builtins.readFile (pkgs.replaceVarsWith {
            src = ./gamescope-dummy.sh;
            isExecutable = true;
          }));
        in
        (old.extraProfile or "") + ''
          export PATH=${gamescopeDummy}/bin:$PATH
        '';
    });

    desktop = steamBase.override (old: (steamSharedOverride old) // {
      # NOTE: Replace gamescope with SPECIFICALLY the stable channel - without Jovian overlay
      extraProfile = (old.extraProfile or "") + ''
        export MANGOHUD=1
      '';
    });
  };

in
{
  imports = [
    ./decky.nix
  ];

  # Boot into Steam automatically
  services.displayManager = {
    defaultSession = "steam";
    autoLogin = {
      enable = true;
      user = "faupi";
    };
  };

  programs = {
    steam = {
      enable = true;
      package = steamConfig.desktop;
      extest.enable = true; # X11->Wayland SteamInput mapping #TODO: Add 64bit to avoid errors?
      gamescopeSession = {
        enable = true;
      };

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  # Disable extest from blocking tablet mode
  services.udev.extraRules = ''
    KERNEL=="event[0-9]*", ATTRS{name}=="extest fake device", TAG+="kwin-ignore-tablet-mode"
  '';

  # Sync gamescope-session Steam with our system one, so the same bwrap arguments apply
  nixpkgs.overlays = [
    (final: prev: {
      gamescope-session = prev.gamescope-session.override {
        steam = steamConfig.gamescope;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    (makeAutostartItem rec {
      name = "steam";
      package = makeDesktopItem {
        inherit name;
        desktopName = "Steam";
        exec = "steam -silent %U";
        icon = "steam";
        extraConfig = {
          OnlyShowIn = "KDE";
        };
      };
    })

    steamtinkerlaunch
  ];
}
