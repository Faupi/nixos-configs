{ pkgs, config, lib, ... }:
with lib;
{
  home.packages = with pkgs; [
    qpwgraph
    (config.lib.nixgl.wrapPackage filelight)
    (config.lib.nixgl.wrapPackage krita)
  ];
}
