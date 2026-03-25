{ pkgs, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = "gamestream";
    };
  };

  programs.labwc = {
    enable = true;
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

      export WLR_BACKENDS=libinput,headless
      export WLR_HEADLESS_OUTPUTS=1

      export _JAVA_AWT_WM_NONREPARENTING=1

      systemctl --user import-environment \
        XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP \
        WLR_BACKENDS WLR_HEADLESS_OUTPUTS

      exec systemd-cat --identifier=labwc labwc "$@"
    '')
  ];

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
        if wlr-randr 2>/dev/null | grep -q "^HEADLESS-1"; then
          break
        fi
        sleep 0.1
      done
      # Set up display defaults (streaming res set by sunshine on connection)
      wlr-randr --output HEADLESS-1 --custom-mode 1920x1080@60Hz --scale 1 --on

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

  programs = {
    steam = {
      enable = true;
      extest.enable = false;

      extraCompatPackages = with pkgs; [
        (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
      ];
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamemode.enable = true;
  };

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
        lan_encryption_mode = 2; # "encryption is mandatory and unencrypted connections are rejected"
        origin_web_ui_allowed = "lan";
        upnp = "disabled";
        global_prep_cmd = builtins.toJSON [
          # Set display properties to match client
          {
            do = /*sh*/''
              sh -c "/run/current-system/sw/bin/wlr-randr \
                --output HEADLESS-1 \
                --custom-mode \"''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz\" \
                --scale 1"
            '';
            undo = "sh -c 'true'";
          }
        ];
      };
    };

    # Add dummy audio sink
    pipewire = {
      extraConfig.pipewire."91-null-sinks" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name" = "support.null-audio-sink";
              "node.name" = "virtual_dummy_sink";
              "node.description" = "Virtual Dummy Sink";
              "media.class" = "Audio/Sink";
              "audio.position" = "FL,FR";
            };
          }
        ];
      };

      wireplumber.extraConfig."90-default-null-sink" = {
        "monitor.rules" = [
          {
            matches = [{ "node.name" = "virtual_dummy_sink"; }];
            actions.update-props."priority.session" = 2000;
          }
        ];
      };
    };
  };
}
