{ pkgs, ... }:
let
  defaultDisplay = "HEADLESS-1";
  defaultAudioSink = "gamestream-sink";
in
{
  flake-configs = {
    audio = {
      enable = true;
      user = "gamestream";
    };
  };

  environment.systemPackages = with pkgs; [
    foot # terminal

    # screen output settings
    wlr-randr

    wl-clipboard # clipboard
    mako # notifications
    pavucontrol # volume control

    # TODO: Rework labwc-session into a service ideally
    (pkgs.writeShellScriptBin "labwc-session" /*sh*/''
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=labwc
      export XDG_CURRENT_DESKTOP=labwc

      export WLR_BACKENDS=libinput,headless
      export WLR_HEADLESS_OUTPUTS=1

      export _JAVA_AWT_WM_NONREPARENTING=1

      systemctl --user import-environment \
        XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP \
        WLR_BACKENDS WLR_HEADLESS_OUTPUTS

      exec systemd-cat --identifier=labwc labwc "$@"
    '')
  ];

  programs.labwc = {
    enable = true;
  };
  environment.etc = {
    # https://labwc.github.io/labwc-config.5.html
    "xdg/labwc/rc.xml".text = /*xml*/''
      <?xml version="1.0"?>
      <labwc_config>

      <core>
        <autoEnableOutputs>no</autoEnableOutputs>
      </core>

      <libinput>
        <device category="non-touch">
          <accelProfile>flat</accelProfile>
          <pointerSpeed>-0.7</pointerSpeed>
        </device>
      </libinput>

      </labwc_config>
    '';

    "xdg/labwc/autostart".text = /*sh*/''
      # Wait for headless display
      for i in $(seq 1 50); do
        if wlr-randr 2>/dev/null | grep -q "^${defaultDisplay}"; then
          break
        fi
        sleep 0.1
      done
      # Set up display defaults (streaming res set by sunshine on connection)
      wlr-randr --output "${defaultDisplay}" --custom-mode 1920x1080@60Hz --scale 1 --on

      # Sync systemd environment
      systemctl --user import-environment WAYLAND_DISPLAY

      # Since we're missing graphical-session.target, run sunshine manually
      systemctl start --user sunshine

      systemd-cat --identifier=steam steam -silent &
  
    '';

    "xdg/foot/foot.ini".text = /*ini*/''
      font=monospace:size=11
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "wlr" "gtk" ];
  };

  security.polkit.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;
    xserver.enable = false; # Assuming no other Xserver needed
    libinput.enable = true;

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "labwc-session";
          user = "gamestream";
        };

        default_session = initial_session;
      };
    };

    sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;
      capSysAdmin = false;
      settings = {
        system_tray = false; # No tray
        controller = "enabled";
        back_button_timeout = 2000;
        keyboard = "enabled";
        mouse = "enabled";
        native_pen_touch = "enabled";
        encoder = "hardware";

        stream_audio = true;
        output_name = defaultDisplay;

        virtual_sink = "${defaultAudioSink}.monitor";

        lan_encryption_mode = 2; # "encryption is mandatory and unencrypted connections are rejected"
        origin_web_ui_allowed = "lan";
        upnp = "disabled";

        global_prep_cmd = builtins.toJSON [
          # Set display properties to match client
          {
            do = pkgs.writeShellScript "update-display" /*sh*/''
              /run/current-system/sw/bin/wlr-randr \
                --output "${defaultDisplay}" \
                --custom-mode "''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz" \
                --scale 1
            '';
          }
        ];
      };
    };

    # Add virtual audio sink
    pipewire = {
      extraConfig.pipewire."91-null-sinks" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = defaultAudioSink;
              "node.description" = "Gamestream virtual sink";
              "media.class" = "Audio/Sink";

              # Try to be the default at all times
              "priority.session" = 2000;
              "priority.driver" = 2000;
            };
          }
        ];
      };
    };
  };
}
