{ inputs, lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  imports = [
    inputs.mangowm.hmModules.mango
  ];

  wayland.windowManager.mango = {
    enable = true;

    systemd = {
      enable = true;
      xdgAutostart = true;
    };

    settings = {
      focus_on_activate = false; # Do not focus windows when they request attention
      sloppyfocus = true; # Edge-scrolling with cursor is disabled, so it shouldn't move the view
      warpcursor = true; # Warp cursor to focus
      axis_bind_apply_timeout = 0; # Pick up all scroll events with no cooldown

      # Input
      mouse_accel_profile = 1;
      mouse_accel_speed = -0.8;
      xkb_rules_layout = "us,cz";
      xkb_rules_variant = "mac,qwerty-mac";

      # Scrolling layout all the way until I find a reason to use anything else
      tagrule = [
        "id:1,layout_name:scroller"
        "id:2,layout_name:scroller"
        "id:3,layout_name:scroller"
        "id:4,layout_name:scroller"
        "id:5,layout_name:scroller"
        "id:6,layout_name:scroller"
        "id:7,layout_name:scroller"
        "id:8,layout_name:scroller"
        "id:9,layout_name:scroller"
      ];
      scroller_default_proportion = 0.6;
      scroller_focus_center = 0;
      scroller_prefer_center = 0;
      scroller_default_proportion_single = 1.0;
      scroller_proportion_preset = "0.5,0.8,1.0";
      edge_scroller_pointer_focus = false; # Do not auto-focus off-screen windows

      # Animations
      tag_animation_direction = 0; # Tags/workspaces are vertical, windows horizontal
      animation_duration_move = 150;
      animation_duration_open = 200;
      animation_duration_tag = 200;
      animation_duration_close = 200;
      animation_duration_focus = 0;

      # Mouse SUPER-left and right to move and resize windows
      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];

      # Mouse binds (scroll)
      axisbind = [
        # Workspace navigation
        "SUPER,DOWN,viewtoright"
        "SUPER,UP,viewtoleft"

        # Move focused window to adjacent workspace
        "SUPER+CTRL,DOWN,tagtoright"
        "SUPER+CTRL,UP,tagtoleft"

        # Focus next/previous window
        "SUPER+SHIFT,DOWN,focusdir,right"
        "SUPER+SHIFT,UP,focusdir,left"
      ];

      bind = [
        # Cycle layouts
        "SUPER,SPACE,switch_keyboard_layout"

        # Lock
        "SUPER+ALT,L,spawn,dms ipc call lock lock"

        # Spotlight
        "SUPER+ALT+CTRL+SHIFT,O,spawn,dms ipc spotlight toggle"

        # Applications
        "SUPER,E,spawn,dolphin"
        "SUPER,T,spawn,konsole"

        # DMS
        "SUPER,N,spawn,dms ipc call notepad toggle"
        "SUPER,V,spawn,dms ipc call clipboard toggle"

        # Cycle widths
        "SUPER,F,switch_proportion_preset"

        # Fullscreen
        "SUPER+SHIFT,F,togglefullscreen"

        # Maximize
        "SUPER+CTRL,F,togglemaximizescreen"

        # Toggle floating
        "SUPER+ALT,F,togglefloating"

        # Kill window
        "SUPER,Q,killclient"

        # Overview
        "SUPER,O,toggleoverview"

        # Media
        "NONE,XF86AudioPlay,spawn,dms ipc call mpris playPause"
        "NONE,XF86AudioPrev,spawn,dms ipc call mpris previous"
        "NONE,XF86AudioNext,spawn,dms ipc call mpris next"

        # Volume
        "NONE,XF86AudioLowerVolume,spawn,dms ipc call audio decrement 5"
        "NONE,XF86AudioRaiseVolume,spawn,dms ipc call audio increment 5"

        # View tags
        "SUPER,1,view,1"
        "SUPER,2,view,2"
        "SUPER,3,view,3"
        "SUPER,4,view,4"
        "SUPER,5,view,5"
        "SUPER,6,view,6"
        "SUPER,7,view,7"
        "SUPER,8,view,8"
        "SUPER,9,view,9"

        # Move window to tag
        "SUPER+SHIFT,1,tag,1"
        "SUPER+SHIFT,2,tag,2"
        "SUPER+SHIFT,3,tag,3"
        "SUPER+SHIFT,4,tag,4"
        "SUPER+SHIFT,5,tag,5"
        "SUPER+SHIFT,6,tag,6"
        "SUPER+SHIFT,7,tag,7"
        "SUPER+SHIFT,8,tag,8"
        "SUPER+SHIFT,9,tag,9"

        # Region screenshot
        "NONE,Print,spawn_shell,wlr-shot screenshot --clipboard --select"

        # NOTE: For active window / screen, Mango can't pass the information, so we need to provide it manually
        # Window screenshot
        "CTRL,Print,spawn_shell,wlr-shot screenshot --clipboard --window \"$(mmsg get focusing-client | ${getExe pkgs.jq} -r '.foreign_toplevel_id')\""
        # Screen screenshot
        "ALT,Print,spawn_shell,wlr-shot screenshot --clipboard --output \"$(mmsg get focusing-client | ${getExe pkgs.jq} -r '.monitor')\""
      ];

      # DMS
      # exec-once = "dms run"; # NOTE: DMS is managed by systemd on system
      source = [
        # Import all DMS-managed configs
        "~/.config/mango/dms/colors.conf"
        "~/.config/mango/dms/layout.conf"
        "~/.config/mango/dms/cursor.conf"
        "~/.config/mango/dms/outputs.conf"
        "~/.config/mango/dms/windowrules.conf"
        # "~/.config/mango/dms/binds.conf" # Using completely custom binds.
      ];
    };
  };
}
