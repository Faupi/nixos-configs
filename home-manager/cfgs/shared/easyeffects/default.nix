{ config, lib, pkgs, ... }:
with lib; {
  home.packages = with pkgs; [ easyeffects ];

  # TODO: Add check for dconf on system - otherwise easyeffects kinda shits itself with switching and whatnot
  # TODO: Add custom autostart into module that works in gamescope as well for spicy audio goodness

  # Link presets
  home.file.".config/easyeffects/input".source = ./presets/input;
  home.file.".config/easyeffects/output".source = ./presets/output;

  # TODO: Device-to-preset mappings - import from Deck

  dconf.settings = {
    "com/github/wwmm/easyeffects" = {
      use-dark-theme = true;

      # Automatically hook onto new apps and whatnot
      process-all-inputs = true;
      process-all-outputs = true;
    };
  };
}
