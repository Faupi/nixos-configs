{ config, pkgs, lib, fop-utils, ... }:
let
  xdg-wrapper = pkgs.writeShellScript "xdg-wrapper" ''
    unset LD_LIBRARY_PATH
    exec xdg-open $@
  '';
  wrapped-teams = config.lib.nixgl.wrapPackage (
    fop-utils.wrapPkgBinary {
      inherit pkgs;
      package = pkgs.teams-for-linux;
      nameAffix = "xdg";
      arguments = [
        "--defaultURLHandler '${xdg-wrapper}'"
        "--appIcon '${./teams-light.png}'"
      ];
    }
  );
in
{
  home = {
    packages = with pkgs; [
      (config.lib.nixgl.wrapPackage krita)

      wrapped-teams
      # TODO: Move Teams into its own module with configs and this wrapping
      # TODO: Add configuration (dark mode, possible CSS overrides, etc)
      # TODO: Add autostart

      (config.lib.nixgl.wrapPackage epiphany)
    ];

    file = {
      "Teams for Linux autostart" = config.lib.fop-utils.makeAutostartItem {
        name = "teams-for-linux-autostart";
        desktopName = "Microsoft Teams for Linux";
        icon = "teams-for-linux";
        exec = "${lib.getExe wrapped-teams} --minimized";
        noDisplay = true;
      };
    };
  };

  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    _1password = {
      enable = true;
      package = pkgs._1password-gui;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    firefox.profiles.masp.isDefault = true;
  };
}
