{ pkgs, config, lib, ... }:
with lib;
{
  home.packages = with pkgs; map (x: (config.lib.nixgl.wrapPackage x)) [
    qpwgraph # PipeWire visual config
    filelight # Storage space analyzer
    krita # Image editor
    haruna # Video player
  ];
}
