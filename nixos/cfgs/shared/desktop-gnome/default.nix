{ config, pkgs, lib, fop-utils, ... }:
let
  cfg = config.flake-configs.gnome;
in
{
  options.flake-configs.gnome = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable (
      fop-utils.recursiveMerge [
        # Display
        {
          services = {
            xserver = {
              enable = true;
              excludePackages = [ pkgs.xterm ];
            };
            displayManager.gdm = {
              enable = lib.mkDefault true;
              wayland = true;
            };
          };
        }

        # Desktop
        {
          # Desktop Portal
          xdg.portal = {
            enable = true;
            xdgOpenUsePortal = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-gnome
            ];

            config = {
              common = {
                default = "gnome";
              };
            };
          };

          services.displayManager.defaultSession = lib.mkDefault "gnome";

          services.desktopManager.gnome.enable = true;

          environment.gnome.excludePackages = with pkgs; [
            gnome-tour
            gnome-music
            gnome-text-editor
            yelp
          ];

          environment.systemPackages = with pkgs; [
            p7zip
            unrar

            gnome-disk-utility
            gnome-tweaks
            gnome-extension-manager
          ];

          programs.dconf.enable = true;

          # Allow GNOME Shell Extensions website integration
          services.gnome.gnome-browser-connector.enable = true;
        }

        # Auth
        {
          # Enable GNOME Keyring unlock on user login
          services.gnome.gnome-keyring.enable = true;
          security.pam.services.gdm.enableGnomeKeyring = true;
        }
      ]
    ))
  ];
}
