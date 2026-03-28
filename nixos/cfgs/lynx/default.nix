{ pkgs, ... }@args:
let
  cfg = {
    user = "gamestream";
    defaultDisplay = "HEADLESS-1";
    defaultAudioSink = "gamestream-sink";
  };
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./graphics.nix
    ./hardware.nix
    ./session.nix
    ./swap.nix
  ]);

  flake-configs = {
    gaming.enable = true;
    vr.enable = true;
  };

  services.openssh.enable = true;
  system.autoUpgrade.enable = true;

  boot.ntsync.enable = true;

  # TODO: Prohibit nix-shell usage (remote desktop, anything could happen here.)
  users.users.${cfg.user} = {
    isNormalUser = true;
    description = "Game streamer";
    extraGroups = [ "seat" "video" "input" "uinput" "gamemode" ];
  };

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
}
