{ pkgs, config, ... }:
{
  imports = [
    ./fonts.nix
    ./desktop-file-sync.nix
  ];

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
    gwenview
  ])));
}
