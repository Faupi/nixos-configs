{ pkgs, ... }@args:
let
  cfg = {
    user = "gamestream";
    defaultDisplay = "Virtual-1";
    defaultAudioSink = "gamestream-sink";
  };
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./boot.nix
    ./graphics.nix
    ./hardware.nix
    ./mic.nix
    ./session.nix
    ./swap.nix
  ]);

  flake-configs = {
    gaming.enable = true;
    vr.enable = true;
  };

  system.autoUpgrade.enable = true;

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

  services = {
    openssh.enable = true;

    # Auto-nice
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
    };
  };

  system.stateVersion = "25.11";
}
