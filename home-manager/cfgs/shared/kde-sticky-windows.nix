{ pkgs, ... }:
let
  package = pkgs.kde-sticky-windows;
in
{
  home.packages = [ package ];
  programs.plasma.configFile.kwinrc = {
    Plugins."${package.pluginName}Enabled" = true; # Auto-enable
  };
}
