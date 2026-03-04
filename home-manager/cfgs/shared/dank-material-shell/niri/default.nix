{ lib, ... }:
let
  # Helper to apply mkForce on every attribute, in this case binds.
  # If a bind is defined here at all, it will use the config here even if it has a default
  mkForceBinds = binds:
    lib.mapAttrs (_: v: lib.mkForce v) binds;
in
{
  imports = [
    ./default-keybinds.nix
  ];

  config = {
    programs.niri.settings = {
      input = {
        mouse = {
          accel-profile = "flat";
          accel-speed = -0.8;
        };
        keyboard = {
          xkb = {
            layout = "us,cz";
            variant = "mac,qwerty-mac";
          };
        };
      };

      binds = mkForceBinds {
        "Super+Space".action.switch-layout = "next";
        "Super+Alt+L" = {
          action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];
          hotkey-overlay.title = "Lock Screen";
          repeat = false;
          allow-inhibiting = false;
        };
        "Super+Alt+Ctrl+Shift+O" = {
          action.spawn = [ "dms" "ipc" "spotlight" "toggle" ];
          hotkey-overlay.title = "(Super): Toggle Application Launcher";
          repeat = false;
          allow-inhibiting = false;
        };
        "Mod+T" = {
          action.spawn = [ "kitty" ];
          hotkey-overlay.title = "Launch Kitty";
          repeat = false;
          allow-inhibiting = false;
        };
        "Mod+N" = {
          action.spawn = [ "dms" "ipc" "call" "notepad" "toggle" ];
          hotkey-overlay.title = "Notepad: Toggle";
          repeat = false;
          allow-inhibiting = false;
        };
        "Mod+V" = {
          action.spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
          hotkey-overlay.title = "Clipboard: Toggle";
          repeat = false;
          allow-inhibiting = false;
        };

        # Media
        "XF86AudioPlay" = {
          action.spawn = [ "dms" "ipc" "call" "mpris" "playPause" ];
          hotkey-overlay.hidden = true;
          allow-when-locked = true;
          repeat = false;
          allow-inhibiting = false;
        };
        "XF86AudioPrev" = {
          action.spawn = [ "dms" "ipc" "call" "mpris" "previous" ];
          hotkey-overlay.hidden = true;
          allow-when-locked = true;
          repeat = false;
          allow-inhibiting = false;
        };
        "XF86AudioNext" = {
          action.spawn = [ "dms" "ipc" "call" "mpris" "next" ];
          hotkey-overlay.hidden = true;
          allow-when-locked = true;
          repeat = false;
          allow-inhibiting = false;
        };

        # Audio
        "XF86AudioLowerVolume" = {
          action.spawn = [ "dms" "ipc" "call" "audio" "decrement" "5" ];
          hotkey-overlay.hidden = true;
          repeat = true;
          allow-inhibiting = false;
          allow-when-locked = true;
        };
        "XF86AudioRaiseVolume" = {
          action.spawn = [ "dms" "ipc" "call" "audio" "increment" "5" ];
          hotkey-overlay.hidden = true;
          repeat = true;
          allow-inhibiting = false;
          allow-when-locked = true;
        };
      };

      hotkey-overlay.skip-at-startup = true;
    };
  };
}
