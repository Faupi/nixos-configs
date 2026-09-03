{ inputs, pkgs, config, lib, ... }@args:
let
  inherit (lib) mkEnableOption mkIf getExe';
  cfg = config.flake-configs.mango;
in
{
  imports = [
    inputs.mangowm.nixosModules.mango
    inputs.dms.nixosModules.default
  ] ++ (map (mod: (import mod (args // { inherit cfg; }))) [
    ./display-manager.nix
    ./kde-workarounds.nix
  ]);

  options.flake-configs.mango = {
    enable = mkEnableOption "Mango";
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;

    xdg = {
      mime.enable = true;
      icons.enable = true;
      menus.enable = true;

      portal = {
        enable = true;
        wlr = {
          enable = true;
          settings = {
            screencast = {
              chooser_type = "simple";
              chooser_cmd = getExe' pkgs.unstable.wlr-utils "wlr-chooser";
            };
          };
        };
        xdgOpenUsePortal = false;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];

        config = {
          common = {
            # Defaults https://mangowm.github.io/docs/configuration/xdg-portals
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
            "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
            "org.freedesktop.impl.portal.Inhibit" = "none";
          };
        };
      };
    };

    # xdg-desktop-portal-wlr chooser fallback in case the main fails
    systemd.user.services.xdg-desktop-portal-wlr.path = with pkgs; [
      wmenu # Needed for screencast window selection
    ];

    # Session
    programs.mango = {
      enable = true;
      addLoginEntry = false; # Managed through uwsm

      # Remove default session from mango as we manage it via UWSM
      package = pkgs.symlinkJoin {
        name = "mango-no-session";
        paths = [ inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango ];

        postBuild = ''
          rm -f $out/share/wayland-sessions/mango.desktop
        '';
      };
    };
    programs.uwsm = {
      enable = true;

      waylandCompositors.mango = {
        prettyName = "Mango";
        comment = "MangoWM";
        binPath = "/run/current-system/sw/bin/mango";
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

    environment = {
      systemPackages = with pkgs; [
        unstable.wlr-utils # Screenshots, recording, etc.

        # DMS currently does not have network editing, but has applet - we want just the editor
        (networkmanagerapplet.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + /*sh*/''
              substituteInPlace nm-applet.desktop.in \
                --replace-fail \
                  "NotShowIn=KDE;GNOME;COSMIC;" \
                  "NotShowIn=KDE;GNOME;COSMIC;mango;"
            '';
        }))
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = 1;
        ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      };
    };
  };
}

