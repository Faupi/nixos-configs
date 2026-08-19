{ inputs, lib, pkgs, ... }:
let
  inherit (lib) getExe;
in
{
  imports = [
    inputs.mangowm.hmModules.mango
    ./terminal-scratchpad.nix
  ];

  wayland.windowManager.mango = {
    enable = true;

    systemd = {
      enable = true;
      xdgAutostart = true;
    };

    settings = {
      focus_on_activate = 0; # Do not focus windows when they request attention
      sloppyfocus = 1; # Focus windows when hovered
      edge_scroller_pointer_focus = 1; # Scroll hover-focused windows fully into view
      warpcursor = 0; # Warp cursor when focus changes with keyboard
      axis_bind_apply_timeout = 25; # Scroll cooldown

      # Visual
      blur = 0;
      shadows = 1;
      shadow_only_floating = 1;

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
        # NOTE: Normal maximize has issues with e.g. YouTube fullscreening, where it returns back to unmaximized window after exiting fullscreen
        "SUPER+CTRL,F,set_proportion,1.015"

        # Toggle floating
        "SUPER+ALT,F,togglefloating"

        # Kill window
        "SUPER,Q,killclient"

        # Overview
        "ALT,TAB,toggleoverview"
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
        # NOTE: Screenshot commands are split to shell apps to avoid getting cut by mango. There is a character limit, window screenshot already hits it.
        (
          let
            command = getExe (pkgs.writeShellApplication {
              name = "mango-region-screenshot";
              runtimeInputs = with pkgs; [
                wlr-utils
                libnotify
              ];
              text = /*sh*/''
                wlr-shot screenshot --clipboard --select &&
                  notify-send --urgency=low --app-name=Mango --transient 'Region captured to clipboard'
              '';
            });
          in
          "NONE,Print,spawn_shell,${command}"
        )

        # NOTE: For active window / screen, Mango can't pass the information, so we need to provide it manually
        # Window screenshot
        (
          let
            command = getExe (pkgs.writeShellApplication {
              name = "mango-window-screenshot";
              runtimeInputs = with pkgs; [
                wlr-utils
                jq
                libnotify
              ];
              text = /*sh*/''
                wlr-shot screenshot --clipboard --window "$(mmsg get focusing-client | jq -r '.foreign_toplevel_id')" &&
                  notify-send --urgency=low --app-name=Mango --transient 'Window captured to clipboard'
              '';
            });
          in
          "CTRL,Print,spawn_shell,${command}"
        )
        # Screen screenshot
        (
          let
            command = getExe (pkgs.writeShellApplication {
              name = "mango-display-screenshot";
              runtimeInputs = with pkgs; [
                wlr-utils
                jq
                libnotify
              ];
              text = /*sh*/''
                wlr-shot screenshot --clipboard --output "$(mmsg get focusing-client | jq -r '.monitor')" &&
                  notify-send --urgency=low --app-name=Mango --transient 'Screen captured to clipboard'
              '';
            });
          in
          "ALT,Print,spawn_shell,${command}"
        )
      ];

      windowrule = [
        "appid:^com.danklinux.dms$,title:^Authentication$,isfloating:1,isoverlay:1"
        "appid:^org.telegram.desktop$,title:Media viewer,isfloating:1,isfullscreen:1,animation_type_open:none"
        "appid:^discord$,title:Discord Popout,width:640,height:360,isfloating:1,isoverlay:1,isglobal:1"
        "appid:^zen$,title:Picture-in-Picture,width:640,height:360,isfloating:1,isoverlay:1,isglobal:1"
        "appid:^xdg-desktop-portal-gtk$,width:1024,height:720,isfloating:1" # File picker, usually

        # Catch wine trays and throw them into the discard tag 9, let's be honest 99% of explorer.exe is just going to be the tray. (Especially if the title is empty.)
        "appid:^explorer.exe$,title:^$,isfloating:0,isglobal:0,isopensilent:1,tags:9"

        # Don't let Steam games float, happens a lot otherwise. Fake fullscreen to stop games unfullscreening on their own
        # NOTE: steam_app_<id> applies to only some games, e.g. Scrap Mechanic, while others use their own, e.g. Helldivers 2
        # NOTE: force_render:1 could be interesting to test if it makes games happier
        "appid:^steam_app_,isfloating:0,isfakefullscreen:1"
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
        "~/.config/mango/dms/binds.conf" # Mostly for ad-hoc overlays
      ];
    };
  };
}
