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
    kanshi

    wl-clipboard # clipboard
    mako # notifications
    pavucontrol # volume control

    # screenshots
    slurp
    grim

    (pkgs.writeShellScriptBin "labwc-session" /*sh*/''
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=labwc
      export XDG_CURRENT_DESKTOP=labwc

      export WLR_BACKENDS=drm,libinput

      export _JAVA_AWT_WM_NONREPARENTING=1

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
      kanshi &
      sunshine &
      
    '';

    "xdg/kanshi/config".text = ''
      profile {
        output Virtual-1 mode 2560x1600@144Hz enable
      }
    '';

    "xdg/foot/foot.ini".text = /*ini*/''
      font=monospace:size=11
    '';
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
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
        controller = "enabled";
        back_button_timeout = 2000;
        keyboard = "enabled";
        mouse = "enabled";
        native_pen_touch = "enabled";
        encoder = "hardware";
        lan_encryption_mode = 2;
      };
    };
  };
}
