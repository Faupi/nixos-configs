{ pkgs, cfg, lib, ... }:
let
  inherit (lib) getExe;
in
{
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
      wofi # launcher
      wlr-randr # screen output settings
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

        <keyboard>
          <default /> <!-- Use defaults -->
          <keybind key="W-Return">
            <action name="Execute" command="${getExe pkgs.wofi} --show drun"/>
          </keybind>
        </keyboard>

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

      "xdg/wofi/config".text = /*ini*/''
        show=drun
        allow_images=true
        image_size=24
      '';
      "xdg/wofi/style.css".source =
        let
          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "wofi";
            rev = "9180ba3ddda7d339293e8a1bf6a67b5ce37fdd6e";
            hash = "sha256-qC1IvVJv1AmnGKm+bXadSgbc6MnrTzyUxGH2ogBOHQA=";
          };
        in
        "${src}/style.css";
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
        chooser_cmd = "${getExe pkgs.slurp} -f 'Monitor: %o' -or";
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

  networking = {
    interfaces.${cfg.mainInterface}.wakeOnLan.enable = true;
    firewall.interfaces.${cfg.mainInterface}.allowedUDPPorts = [ 9 ];
  };
}
