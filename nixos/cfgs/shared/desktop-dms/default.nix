{ inputs, pkgs, config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkDefault mkForce;
  cfg = config.flake-configs.dank-material-shell;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.dms.nixosModules.default

    ./kde-workarounds.nix
  ];

  options.flake-configs.dank-material-shell = {
    enable = mkEnableOption "Dank Material Shell";
  };

  config = mkIf cfg.enable {
    services.displayManager.defaultSession = mkDefault "niri";

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    niri-flake.cache.enable = true;
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    # https://danklinux.com/docs/dankmaterialshell/nixos-flake#polkit-agent
    systemd.user.services.niri-flake-polkit.enable = false;
    services.gnome.gnome-keyring.enable = true;

    xdg = {
      mime.enable = true;
      icons.enable = true;
      menus.enable = true;

      portal = {
        enable = true;
        wlr.enable = false; # Enabling could cause issues
        xdgOpenUsePortal = false;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];

        config = {
          common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
          };

          niri = {
            "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            "org.freedesktop.impl.portal.Screenshot" = "gnome";
          };
        };
      };
    };

    programs.dank-material-shell = {
      enable = true;
      dgop.package = mkForce inputs.dgop.packages.${pkgs.system}.dgop;

      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableClipboardPaste = true; # Pasting items from the clipboard (wtype)
    };

    # Only start DMS inside niri. (don't attempt in gamescope)
    # + Run xdg autostart after DMS is actually ready (works around the classic tray issue)
    #   https://github.com/AvengeMedia/DankMaterialShell/issues/1073#issuecomment-3896573727
    systemd.user.services.dms = {
      serviceConfig.ExecStartPost = "${pkgs.coreutils}/bin/sleep 5";
      unitConfig = {
        ConditionEnvironment = [
          "XDG_CURRENT_DESKTOP=niri"
        ];
        PartOf = [ "niri.service" ];
        After = [ "niri.service" ];
        Before = [ "xdg-desktop-autostart.target" ];
      };
    };

    services = {
      # Make Super work on its own for binds
      # (by making it emit something ridiculous)
      keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings.global = {
            overload_tap_timeout = 200; # Milliseconds to register a tap before timeout
          };
          settings.main = {
            leftmeta = "overload(meta, macro(leftmeta+leftcontrol+leftalt+leftshift+o))";
          };
        };
      };

      # Battery read-outs and management
      upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 20;

        percentageCritical = 10;
        percentageAction = 5; # Make sure hibernate runs early enough
        criticalPowerAction = "Hibernate";
      };
    };

    programs.xwayland = {
      enable = true;
      package = pkgs.xwayland-satellite;
    };

    environment.systemPackages = with pkgs; [
      kitty
      kdePackages.dolphin
    ];
  };
}
