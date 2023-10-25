{ config, lib, pkgs, ... }:
with lib; {
  home.packages = with pkgs; [ easyeffects ];

  # TODO: Add check for dconf on system - otherwise easyeffects kinda shits itself with switching and whatnot
  # TODO: Add custom autostart into module that works in gamescope as well for spicy audio goodness

  # Link presets
  # TODO: Redo so it symlinks files instead of directories to still allow configuration
  # TODO: Explore if generating JSONs in nix would be any benefitial
  home.file.".config/easyeffects/input".source = ./presets/input;
  home.file.".config/easyeffects/output".source = ./presets/output;

  # TODO: Device-to-preset mappings - import the rest from Deck
  home.file.".config/easyeffects/autoload/input".source = ./autoload/input;
  home.file.".config/easyeffects/autoload/output".source = ./autoload/output;

  dconf.settings = {
    "com/github/wwmm/easyeffects" = {
      use-dark-theme = true;

      # Automatically hook onto new apps and whatnot
      process-all-inputs = true;
      process-all-outputs = true;
    };
  };
}
