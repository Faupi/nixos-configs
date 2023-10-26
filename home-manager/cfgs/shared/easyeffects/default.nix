# TODO: Add check for dconf and pipewire on system - otherwise easyeffects kinda shits itself with switching and whatnot
# TODO: Add custom autostart into module that works in gamescope as well for spicy audio goodness
# TODO: Explore if generating autoload JSONs in nix would be any benefitial

{ config, lib, pkgs, fop-utils, ... }:
with lib; {
  home.packages = with pkgs; [ easyeffects ];

  # Link presets
  home.file = with fop-utils;
    recursiveMerge [
      (mapDirSources ./presets/input ".config/easyeffects/input")
      (mapDirSources ./presets/output ".config/easyeffects/output")
      (mapDirSources ./autoload/input ".config/easyeffects/autoload/input")
      (mapDirSources ./autoload/output ".config/easyeffects/autoload/output")
    ];

  dconf.settings = {
    "com/github/wwmm/easyeffects" = {
      use-dark-theme = true;

      # Automatically hook onto new apps and whatnot
      process-all-inputs = true;
      process-all-outputs = true;
    };
  };
}
