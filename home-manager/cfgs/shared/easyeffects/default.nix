{ pkgs, ... }:
let
  package = pkgs.stable.easyeffects;
in
{
  home.packages = [
    package
    (pkgs.makeAutostartItem rec {
      name = "easyeffects-service";
      package = pkgs.makeDesktopItem {
        inherit name;
        desktopName = "Easy Effects";
        exec = "easyeffects --gapplication-service";
        icon = "easyeffects";
      };
    })
  ];

  # Link presets
  # TODO: Change to .local path with potentially a new style of config (existing configs do not seem to autoload)
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
