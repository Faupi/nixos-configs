{ pkgs, cfg, lib, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = cfg.user;
    };
  };

  programs = {
    labwc = {
      enable = true;
    };

    uwsm = {
      enable = true;
      waylandCompositors = {
        labwc = {
          prettyName = "labwc";
          comment = "labwc compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/labwc";
        };
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      foot # terminal

      # screen output settings
      wlr-randr

      wl-clipboard # clipboard
      mako # notifications
      pavucontrol # volume control
    ];

    etc = {
      "uwsm/env-labwc".text = /*sh*/''
        export WLR_BACKENDS=drm,libinput
        export WLR_LIBINPUT_NO_DEVICES=1
        export WLR_NO_HARDWARE_CURSORS=1
        export WLR_SCENE_DISABLE_DIRECT_SCANOUT=0
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';

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

        systemd-cat --identifier=steam steam -silent &
  
      '';

      "xdg/foot/foot.ini".text = /*ini*/''
        font=monospace:size=11
      '';
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
      settings.screencast = {
        max_fps = 60;
        chooser_type = "simple";
        chooser_cmd = "${lib.getExe pkgs.slurp} -f 'Monitor: %o' -or";
      };
    };
    config.common = {
      default = [ "wlr" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
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
          command = "uwsm start labwc-uwsm.desktop";
          user = cfg.user;
        };

        default_session = initial_session;
      };
    };

    sunshine = {
      enable = true;
      autoStart = true;
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
            do = lib.getExe (pkgs.writeShellApplication {
              name = "update-display";
              runtimeEnv = {
                inherit (cfg) defaultDisplay;
              };
              runtimeInputs = with pkgs; [
                wlr-randr
              ];
              text = /*sh*/''
                wlr-randr \
                  --output "$defaultDisplay" \
                  --custom-mode "''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz" \
                  --scale 1
              '';
            });
          }
        ];
      };

      applications = {
        apps = [
          {
            name = "Desktop";
          }
          {
            name = "Desktop (Mic)";
            prep-cmd = [
              {
                do = lib.getExe (pkgs.writeShellApplication {
                  name = "sunshine-microphone-setup";
                  runtimeEnv = {
                    inherit (cfg) defaultAudioSource;
                  };
                  runtimeInputs = with pkgs; [
                    pulseaudio
                  ];
                  text = /*sh*/''
                    pactl load-module module-roc-source \
                      fec_code=rs8m \
                      local_ip=0.0.0.0 \
                      local_source_port=10001 \
                      local_repair_port=10002 \
                      local_control_port=10003 \
                      source_name="$defaultAudioSource" \
                      source_properties="node.name=$defaultAudioSource" \
                      > /tmp/sunshine_roc_mod_id

                    pactl set-default-source "$defaultAudioSource"
                  '';
                });
                undo = lib.getExe (pkgs.writeShellApplication {
                  name = "sunshine-microphone-teardown";
                  runtimeEnv = {
                    inherit (cfg) defaultAudioSource;
                  };
                  runtimeInputs = with pkgs; [
                    pulseaudio
                  ];
                  text = /*sh*/''
                    if [ -f /tmp/sunshine_roc_mod_id ]; then
                      pactl unload-module "$(cat /tmp/sunshine_roc_mod_id)"
                      rm /tmp/sunshine_roc_mod_id
                    fi
                  '';
                });
              }
            ];
          }
        ];
      };
    };

    # Add virtual audio sink
    pipewire = {
      extraConfig.pipewire = {
        "90-hardware-clock-emulator" = {
          "context.objects" = [
            {
              factory = "spa-node-factory";
              args = {
                "factory.name" = "support.node.driver";
                "node.name" = "dummy_clock";
                "node.description" = "Headless Master Clock";
                "priority.driver" = 5000;
                "node.always-driver" = true;
                "node.pause-on-idle" = false;
                "clock.quantum" = 240; # WiVRn always tries to be at 240
              };
            }
          ];
        };

        "91-null-sink" = {
          "context.objects" = [
            {
              factory = "adapter";
              args = {
                "factory.name" = "support.null-audio-sink";
                "node.name" = cfg.defaultAudioSink;
                "node.description" = "Gamestream virtual sink";
                "media.class" = "Audio/Sink";
                "audio.position" = "FL,FR";
              };
            }
          ];
        };
      };
    };
  };

  networking = let interface = "enp6s0"; in {
    interfaces.${interface}.wakeOnLan.enable = true;
    firewall.interfaces.${interface}.allowedUDPPorts = [
      # Wake on LAN
      9

      # Sunshine microphone
      10001
      10002
      10003
    ];
  };
}
