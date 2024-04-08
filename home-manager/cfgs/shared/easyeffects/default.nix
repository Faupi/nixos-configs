# TODO: Add custom autostart into module that works in gamescope as well for spicy audio goodness
# TODO: Explore if generating autoload JSONs in nix would be any benefitial

{ pkgs, lib, fop-utils, ... }:
with lib;
let
  package = pkgs.stable.easyeffects;
in
{
  home.packages = [ package ];

  # Autostart
  home.file."EasyEffects autostart" = fop-utils.makeAutostartItemLink pkgs
    {
      name = "easyeffects-service";
      desktopName = "Easy Effects";
      exec = "${getExe package} --gapplication-service";
      icon = "easyeffects";
    }
    {
      systemWide = false;
    };

  # Link presets
  xdg.configFile = {
    # NOTE: It is not possible to recursively symlink nested dictionaries (easyeffects + easyeffects/autoload)
    "EasyEffects presets input" = {
      source = ./presets/input;
      target = "easyeffects/input";
      recursive = true;
    };
    "EasyEffects presets output" = {
      source = ./presets/output;
      target = "easyeffects/output";
      recursive = true;
    };

    "EasyEffects module auto-load mapping" = {
      source = ./autoload;
      target = "easyeffects/autoload";
      recursive = true;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "com/github/wwmm/easyeffects" = {
        use-dark-theme = true;

        # Automatically hook onto new apps and whatnot
        process-all-inputs = true;
        process-all-outputs = true;
      };
    };
  };
}
