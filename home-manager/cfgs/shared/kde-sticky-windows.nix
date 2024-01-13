{ pkgs, ... }:
let
  package = pkgs.kde-sticky-windows;
in
{
  # TODO: Add a wrapper function for KWin scripts
  home.file."KWin script - Sticky window snapping" = {
    source = package;
    target = ".local/share/kwin/scripts/${package.pluginName}/";
    recursive = true;
  };
  programs.plasma.configFile.kwinrc = {
    Plugins."${package.pluginName}Enabled" = true; # Auto-enable
  };
}
