# TODO: Needs more cleanup

{ pkgs, cfg, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = cfg.user;
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment.systemPackages = with pkgs; [
    foot # terminal

    wl-clipboard # clipboard
    mako # notifications
    pavucontrol # volume control
  ];

  environment.etc = {
    # NOTE: For HDR, append `bitdepth, 10` to monitor changes (also in sunshine)
    "xdg/hypr/hyprland.conf".text = ''
      monitor = ${cfg.defaultDisplay}, 1920x1080@144, 0x0, 1

      experimental {
        hdr = false
        xx_color_management_v4 = true
      }
    
      exec-once = steam -silent

      input {
        accel_profile = flat
        force_no_accel = true
        sensitivity = -0.7
      }

      render {
        direct_scanout = 1
      }

      misc {
        vfr = true
        no_direct_scanout = false
      }

      decoration {
        rounding = 0
        blur:enabled = false
        drop_shadow = false
      }
      animations:enabled = false
    '';

    "xdg/foot/foot.ini".text = /*ini*/''
      font=monospace:size=11
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  security.polkit.enable = true;

  services = {
    xserver.enable = false;
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;

    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
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
            do = pkgs.writeShellScript "update-display" /*sh*/''
              ${pkgs.hyprland}/bin/hyprctl keyword monitor \
                "${cfg.defaultDisplay}, ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}, 0x0, 1"
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
