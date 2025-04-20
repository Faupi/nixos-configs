{ pkgs, config, ... }:
{
  imports = [
    ./fonts.nix
    ./mimeapps.nix
  ];

  flake-configs = {
    plasma.enable = true;
  };

  home.packages = (with pkgs; [
    # TODO: Figure out why Haruna fails builds under NixGL
    haruna
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    krita
    kdePackages.filelight
  ]));
}
