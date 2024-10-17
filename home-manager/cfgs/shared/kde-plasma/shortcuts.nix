{ fop-utils, ... }:
{
  programs.plasma.shortcuts = fop-utils.recursiveMerge [

    # Launcher -> KRunner
    {
      "plasmashell" = {
        "activate application launcher" = [ ];
      };
      "services.org\.kde\.krunner\.desktop" = {
        _launch = [ "Search" "Meta" ];
      };
    }

    # Keyboard layout switching
    {
      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = [ ];
        "Switch to Next Keyboard Layout" = [ "Meta+Space" ];
      };
    }

  ];
}
