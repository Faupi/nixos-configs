{ lib, pkgs, config, ... }:
{
  imports = [
    ./desktop-file-sync.nix
    ./fonts.nix
    ./shell
  ];

  services.home-manager = {
    autoExpire = {
      enable = true;
      # Defaults, but might as well have em
      frequency = "monthly";
      timestamp = "-30 days";
    };
  };

  nix = {
    # TODO: Automatically set to matching version with system
    package = lib.mkDefault (pkgs.lix);
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      http-connections = 100; # Binary cache connections limit
    };
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        pull.rebase = false;
        core.autocrlf = false; # Fucks with cross-platform usage, seen as a bad default
      };
    };
  };

  qt.kde.settings = {
    "haruna/haruna.conf" = {
      Playlist = {
        PlaybackBehavior = "StopAfterItem";
      };
    };
  };

  home.packages = (with pkgs; [
    haruna
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    krita
    yad
  ] ++ (with kdePackages; [
    filelight
  ])));
}
