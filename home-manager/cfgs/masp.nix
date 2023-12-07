{ config, pkgs, fop-utils, ... }:
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
      arguments = [ "--defaultURLHandler '${xdg-wrapper}'" ];
    }
  );
in
{
  home.packages = with pkgs;
    [
      spotify

      wrapped-teams
      # TODO: Move Teams into its own module with configs and this wrapping
      # TODO: Add configuration (dark mode, possible CSS overrides, etc)
      # TODO: Add autostart
    ];

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
