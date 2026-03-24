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

    # screenshots
    slurp
    grim

    (pkgs.writeShellScriptBin "labwc-session" /*sh*/''
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=labwc
      export XDG_CURRENT_DESKTOP=labwc

      export WLR_BACKENDS=headless
      export WLR_HEADLESS_OUTPUTS=1
      export WLR_RENDERER=pixman

      export _JAVA_AWT_WM_NONREPARENTING=1

      exec systemd-cat --identifier=labwc labwc "$@"
    '')
  ];

  environment.etc = {
    "xdg/labwc/rc.xml".text = /*xml*/''
      <?xml version="1.0"?>
      <openbox_config>

        <core>
          <autoEnableOutputs>true</autoEnableOutputs>
        </core>

        <libinput>
          <device category="non-touch">
            <accelProfile>flat</accelProfile>
          </device>
        </libinput>

      </openbox_config>
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
    config.common.default = "gtk";
  };

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
    seatd.enable = true;

    getty.autologinUser = "gamestream";
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
      autoStart = true;
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
