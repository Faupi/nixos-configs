{ ... }: {
  imports = [
    ./graphics.nix
    ./session.nix
  ];

  users.users.gamestream = {
    isNormalUser = true;
    description = "Game streamer";
  };
}
