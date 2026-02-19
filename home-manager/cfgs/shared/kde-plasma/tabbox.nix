# Task switcher / tabbox / ALT+TAB 
# - Mostly aimed at minimizing overhead from previewing thumbnails etc when system is under pressure

{ pkgs, cfg, lib, ... }:
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kde.plugins.kwin-windowswitcher-modern-informative
    ];

    programs.plasma.configFile.kwinrc = {
      TabBox = {
        LayoutName = "modern_informative"; # Use our plugin
        OrderMinimizedMode = 1; # Show minimized separately (faded on the bottom)
        HighlightWindows = false; # Do not preview currently highlighted
      };
    };
  };
}
