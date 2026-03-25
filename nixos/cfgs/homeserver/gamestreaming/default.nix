{ ... }: {
  imports = [
    ./graphics.nix
    ./session.nix
  ];

  # TODO: Prohibit nix-shell usage (remote desktop, anything could happen here.)
  users.users.gamestream = {
    isNormalUser = true;
    description = "Game streamer";
    extraGroups = [ "seat" "video" "input" "uinput" "gamemode" ];
  };
}
