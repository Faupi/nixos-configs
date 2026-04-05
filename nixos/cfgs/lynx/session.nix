# TODO: Needs more cleanup

{ pkgs, cfg, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = cfg.user;
    };
  };

  environment.systemPackages = with pkgs; [
    foot # terminal

    # screen output settings
    wlr-randr

    wl-clipboard # clipboard
    mako # notifications
    pavucontrol # volume control

    (pkgs.writeShellScriptBin "labwc-session" /*sh*/''
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=labwc
      export XDG_CURRENT_DESKTOP=labwc

      export WLR_BACKENDS=drm,libinput
      export WLR_HEADLESS_OUTPUTS=1
      export WLR_LIBINPUT_NO_DEVICES=1

      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_SCENE_DISABLE_DIRECT_SCANOUT=0
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
      # Set up display defaults (streaming res set by sunshine on connection)
      # NOTE: In no-virtual-display specialization this can fail - needs to be non-blocking
      wlr-randr --output "${cfg.defaultDisplay}" --custom-mode 1920x1080@60Hz --scale 1 --on || true

      # Sync systemd environment
      systemctl --user import-environment WAYLAND_DISPLAY

      # Since we're missing graphical-session.target, run sunshine manually
      systemctl start --user sunshine
      systemctl start --user wivrn
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
          user = cfg.user;
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
        output_name = cfg.defaultDisplay;

        virtual_sink = "${cfg.defaultAudioSink}.monitor";

        lan_encryption_mode = 2; # "encryption is mandatory and unencrypted connections are rejected"
        origin_web_ui_allowed = "lan";
        upnp = "disabled";

        global_prep_cmd = builtins.toJSON [
          # Set display properties to match client
          {
            do = pkgs.writeShellScript "update-display" /*sh*/''
              /run/current-system/sw/bin/wlr-randr \
                --output "${cfg.defaultDisplay}" \
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
              "node.name" = cfg.defaultAudioSink;
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

  # Wake on LAN
  networking = let interface = "enp6s0"; in {
    interfaces.${interface}.wakeOnLan.enable = true;
    firewall.interfaces.${interface}.allowedUDPPorts = [ 9 ];
  };
}
