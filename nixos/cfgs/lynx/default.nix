{ pkgs, ... }@args:
let
  cfg = {
    user = "gamestream";
    mainInterface = "enp6s0";
    defaultDisplay = "Virtual-1";
    defaultAudioSink = "gamestream_virtual.sink";
    defaultAudioSource = "gamestream_virtual.source";
  };
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./boot.nix
    ./graphics.nix
    ./hardware.nix
    ./playit.nix
    ./samba.nix
    ./session.nix
    ./sleep.nix
    ./sunshine.nix
    ./swap.nix
  ]);

  flake-configs = {
    gaming.enable = true;
    vr = {
      enable = true;
      autoStart = true;
      # NOTE: Sunshine might not be super happy with the defaults being used *shrug*
      defaultSink = cfg.defaultAudioSink;
      defaultSource = cfg.defaultAudioSource;
    };
  };

  system.autoUpgrade.enable = true;

  # TODO: Move user config to a separate file, enable home-manager. Throw OpenXR action config for WayVR in there.
  users.users.${cfg.user} = {
    isNormalUser = true;
    description = "Game streamer";
    group = cfg.user;
    createHome = true;
    extraGroups = [ "seat" "video" "input" "uinput" "gamemode" "playit" ];
  };
  users.groups.${cfg.user} = { };

  programs = {
    steam = {
      enable = true;
      extest.enable = false;
      package = pkgs.steam;

      extraPackages = with pkgs; [
        steamtinkerlaunch
      ];
      extraCompatPackages = with pkgs; [
        (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
        (bleeding.proton-ge-bin.override { steamDisplayName = "GE-Proton (nix-bleeding)"; })
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

    firefox.enable = true;
  };

  services = {
    openssh.enable = true;
    flatpak.enable = true;
  };

  environment.systemPackages = with pkgs; [
    r2modman
  ];

  system.stateVersion = "25.11";
}
