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

  qt.kde.settings."easyeffects/db/easyeffectsrc" = {
    EffectsPipelines = {
      # Do not hook everything, just default devices
      processAllInputs = true;
      processAllOutputs = true;
    };

    Window = {
      inputAutoloadingUsesFallback = true;
      inputAutoloadingFallbackPreset = "in-default";

      outputAutoloadingUsesFallback = true;
      outputAutoloadingFallbackPreset = "out-default";
    };

    Spectrum = {
      dynamicYScale = true; # False would be better but the default zero level is offset.
    };
  };
}
