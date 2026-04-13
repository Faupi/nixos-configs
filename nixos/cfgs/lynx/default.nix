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

  # TODO: Prohibit nix-shell usage (remote desktop, anything could happen here.)
  users.users.${cfg.user} = {
    isNormalUser = true;
    description = "Game streamer";
    group = cfg.user;
    createHome = true;
    extraGroups = [ "seat" "video" "input" "uinput" "gamemode" ];
  };
  users.groups.${cfg.user} = { };

  programs = {
    steam = {
      enable = true;
      extest.enable = false;
      package = pkgs.steam;

      extraCompatPackages = with pkgs; [
        (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
        (bleeding.proton-ge-bin.override { steamDisplayName = "GE-Proton (nix-bleeding)"; })
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
    openssh.enable = true;
  };

  system.stateVersion = "25.11";
}
