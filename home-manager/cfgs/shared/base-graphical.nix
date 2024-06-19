{ pkgs, config, ... }:
{
  # TODO: Figure out why Haruna fails builds under NixGL
  home.packages = (with pkgs; [
    haruna
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    filelight
    krita
  ]));
}
