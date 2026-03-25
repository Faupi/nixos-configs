{ pkgs, ... }: {
  imports = [
    ./graphics.nix
    ./session.nix
  ];

  flake-configs = {
    gaming.enable = true;
    vr.enable = true;
  };

  # TODO: Prohibit nix-shell usage (remote desktop, anything could happen here.)
  users.users.gamestream = {
    isNormalUser = true;
    description = "Game streamer";
    extraGroups = [ "seat" "video" "input" "uinput" "gamemode" ];
  };

  programs = {
    steam = {
      enable = true;
      extest.enable = false;

      extraCompatPackages = with pkgs; [
        (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
      ];
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
