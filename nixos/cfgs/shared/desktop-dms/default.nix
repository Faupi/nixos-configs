{ inputs, pkgs, config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkDefault mkForce mkAfter;
  cfg = config.flake-configs.dank-material-shell;
in
{
  imports = [
    inputs.niri.nixosModules.niri
    inputs.dms.nixosModules.default
  ];

  options.flake-configs.dank-material-shell = {
    enable = mkEnableOption "Dank Material Shell";
  };

  config = mkIf cfg.enable {
    services.displayManager.defaultSession = mkDefault "niri";

    programs.niri = {
      enable = true;
      package = pkgs.niri; # Use upstream nixpkgs niri cuz cache
    };

    # https://danklinux.com/docs/dankmaterialshell/nixos-flake#polkit-agent
    systemd.user.services.niri-flake-polkit.enable = false;

    # Desktop Portal
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
      ];

      config = {
        common = {
          default = "kde";
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

    environment.systemPackages = with pkgs; [
      kitty
      xwayland-satellite # xwayland support
      kdePackages.dolphin

      # Theming support
      libsForQt5.qt5ct
      kdePackages.qt6ct
      adwaita-qt6
    ];
  };
}
