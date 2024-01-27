# TODO: Add check for dconf and pipewire on system - otherwise easyeffects kinda shits itself with switching and whatnot
# TODO: Add custom autostart into module that works in gamescope as well for spicy audio goodness
# TODO: Explore if generating autoload JSONs in nix would be any benefitial

{ pkgs, ... }: {
  home.packages = with pkgs; [ easyeffects ];

  # Link presets
  xdg.configFile = {
    # Dashes are in the names to avoid collisions - potential matching issue https://github.com/nix-community/home-manager/issues/3346
    "EasyEffects-presets" = {
      source = ./presets;
      target = "easyeffects";
      recursive = true;
    };
    "EasyEffects-module-autoload-mapping" = {
      source = ./autoload;
      target = "easyeffects/autoload";
      recursive = true;
    };
  };

  dconf.settings = {
    "com/github/wwmm/easyeffects" = {
      use-dark-theme = true;

      # Automatically hook onto new apps and whatnot
      process-all-inputs = true;
      process-all-outputs = true;
    };
  };
}
