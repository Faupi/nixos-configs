{ pkgs, lib, ... }:
let
  package = pkgs.stable.easyeffects;

  # Safety wrapper to avoid crashes in Steam gamescope
  displayWrapper = pkgs.writeShellScript "easyeffects-display-wrapper" /*sh*/''
    set -eu
    rt="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      if [ -S "$rt/gamescope-0" ]; then
        export WAYLAND_DISPLAY=gamescope-0
      fi
    fi

    exec ${lib.getExe package} --service-mode --hide-window
  '';
in
{
  services.easyeffects = {
    enable = true;
    inherit package;
  };

  systemd.user.services.easyeffects = {
    Service = {
      ExecStart = lib.mkForce displayWrapper;

      # Avoid too much log spam
      LogRateLimitIntervalSec = "5s";
      LogRateLimitBurst = 20;

      # Trade realtime for higher priority to keep audio without choking the system
      RestrictRealtime = true;
      LimitRTPRIO = 0;
      CPUWeight = 200;
      Nice = -5;
    };
  };

  # Link presets
  xdg.dataFile = {
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
