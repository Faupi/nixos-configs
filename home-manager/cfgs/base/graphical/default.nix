{ pkgs, config, ... }:
{
  imports = [
    ./fonts.nix
    ./mimeapps.nix
  ];

  flake-configs = {
    plasma = {
      enable = true;
      reloadOnActivation = true;
      theme.enable = true;
    };
  };

  home.packages = (with pkgs; [
    haruna
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    krita
    kdePackages.filelight
  ]));
}
