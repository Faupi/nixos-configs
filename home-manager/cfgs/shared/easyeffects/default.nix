{ pkgs, lib, ... }:
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

  # Enable preset fallbacks
  home.activation =
    let
      toIniValue = v:
        if lib.isBool v then
          (if v then "true" else "false")
        else
          toString v;

      overlayIni = path: overlayNix:
        let
          mkIniCommands =
            let
              sectionToCmds = section: opts:
                lib.mapAttrsToList
                  (key: value:
                    ''
                      ${lib.getExe pkgs.crudini} \
                        --set "$SRC" \
                        ${lib.escapeShellArg section} \
                        ${lib.escapeShellArg key} \
                        ${lib.escapeShellArg (toIniValue value)}
                    ''
                  )
                  opts;
            in
            lib.concatStringsSep "\n" (
              lib.flatten (lib.mapAttrsToList sectionToCmds overlayNix)
            );
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          set -euo pipefail
          SRC="${path}"
          DIR="$(dirname "$SRC")"
          mkdir -p "$DIR"

          # Ensure file exists so crudini has something to work on
          touch "$SRC"

          ${mkIniCommands}
        '';
    in
    {
      defaultFallbacks = overlayIni "$HOME/.config/easyeffects/db/easyeffectsrc" {
        Window = {
          inputAutoloadingUsesFallback = true;
          inputAutoloadingFallbackPreset = "in-default";

          outputAutoloadingUsesFallback = true;
          outputAutoloadingFallbackPreset = "out-default";
        };
      };
    };
}
