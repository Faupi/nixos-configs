{ fop-utils, ... }:
fop-utils.recursiveMerge [
  # Launcher -> KRunner
  {
    programs.plasma.shortcuts = {
      "plasmashell" = {
        "activate application launcher" = [ ];
      };
      "services.org\.kde\.krunner\.desktop" = {
        _launch = [ "Search" "Meta" ];
      };
    };
  }
]
