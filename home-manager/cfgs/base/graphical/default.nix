{ pkgs, config, ... }:
{
  imports = [
    ./fonts.nix
    ./desktop-file-sync.nix
  ];

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
