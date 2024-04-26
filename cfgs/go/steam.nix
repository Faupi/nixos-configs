{ config, pkgs, lib, ... }:
with lib;
{
  services.xserver.displayManager.defaultSession = "steam-wayland";

  programs.steam = {
    enable = true;
    extest.enable = true; # X11->Wayland SteamInput mapping
    platformOptimizations.enable = true; # SteamOS tweaks
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = [
    (pkgs.makeAutostartItem rec {
      name = "steam";
      package = pkgs.makeDesktopItem {
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
    desktopSession = "plasmawayland";

    # Make sure the gamescope also sees the compat tools
    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = makeSearchPathOutput "steamcompattool" "" config.programs.steam.extraCompatPackages;
    };
  };

  jovian.decky-loader = {
    enable = true;
    user = "faupi"; # https://github.com/Jovian-Experiments/Jovian-NixOS/blob/1171169117f63f1de9ef2ea36efd8dcf377c6d5a/modules/decky-loader.nix#L80-L84
    extraPackages = with pkgs; [
      curl
      unzip
      util-linux
      gnugrep

      readline.out
      procps
      pciutils
      libpulseaudio
    ];

    extraPythonPackages = pythonPackages: with pythonPackages; [
      pyyaml # hhd-decky
    ];
  };
}
