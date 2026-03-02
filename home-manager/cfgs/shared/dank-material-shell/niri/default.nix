{ ... }: {
  programs.niri.settings = {
    input = {
      mouse = {
        accel-profile = "flat";
        accel-speed = -0.8;
      };
    };

    binds = {
      "Super+Space" = {
        # hotkey-overlay-title = "Toggle Application Launcher";
        action.spawn = [ "dms" "ipc" "spotlight" "toggle" ];
      };

      # Workspace
      "Shift+Super+WheelScrollUp".action.focus-column-left = { };
      "Shift+Super+WheelScrollDown".action.focus-column-right = { };
      "Shift+Super+Left".action.focus-column-left = { };
      "Shift+Super+Right".action.focus-column-right = { };

      # Media
      "XF86AudioPlay" = {
        action.spawn = [ "dms" "ipc" "call" "mpris" "playPause" ];
        allow-when-locked = true;
      };
      "XF86AudioPrev" = {
        action.spawn = [ "dms" "ipc" "call" "mpris" "previous" ];
        allow-when-locked = true;
      };
      "XF86AudioNext" = {
        action.spawn = [ "dms" "ipc" "call" "mpris" "next" ];
        allow-when-locked = true;
      };
    };
  };
}
