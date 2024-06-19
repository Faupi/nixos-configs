{ pkgs, config, lib, ... }:
with lib;
{
  # TODO: Figure out why Haruna fails builds
  home.packages = with pkgs; [
    haruna # Video player
  ]
  ++ (with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    qpwgraph # PipeWire visual config
    filelight # Storage space analyzer
    krita # Image editor
  ]);
}
