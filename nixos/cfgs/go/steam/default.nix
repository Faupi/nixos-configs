{ config, pkgs, lib, ... }:
with lib;
let

  steamBase = pkgs.steam;

  steamShared = (old: {
    globalDeckArgs = false;

    # Mount the decky themes directory under the user so it can be served under the same host
    extraBwrapArgs = [
      "--ro-bind ${config.jovian.decky-loader.stateDir}/themes $HOME/.local/share/Steam/steamui/themes_custom"
    ];

    # Scope some environment variables for whole Steam so that for example MoonDeck knows where to look for things
    extraEnv = {
      DECKY_HOME = config.jovian.decky-loader.stateDir;
    };
  });

  steamConfig = {
    gamescope = steamBase.override (old: (steamShared old));
    desktop = steamBase.override (old: (steamShared old) // {
      extraProfile = (old.extraProfile or "") + ''
        export MANGOHUD=1
      '';
    });
  };

in
{
  imports = [
    ./decky.nix
    ./steamos.nix
  ];

  services.displayManager = {
    defaultSession = "steam-wayland";
    sddm.enable = false; # Jovian handles this
  };

  programs.steam = {
    enable = true;
    extest.enable = true; # X11->Wayland SteamInput mapping
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    package = steamConfig.desktop;
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
  ];

  jovian.steam = {
    enable = true;
    user = "faupi";

    # Session management
    autoStart = true;
    desktopSession = "plasma";

    # Make sure the gamescope also sees the compat tools
    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = makeSearchPathOutput "steamcompattool" "" config.programs.steam.extraCompatPackages;
    };
  };
}
