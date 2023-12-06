{ config, pkgs, ... }:
let
  xdg-wrapper = pkgs.writeShellScript "xdg-wrapper" ''
    unset LD_LIBRARY_PATH
    exec xdg-open $@
  '';
  wrapped-teams = config.lib.nixgl.wrapPackage (
    (pkgs.symlinkJoin {
      name = "${pkgs.teams-for-linux.name}-xdg";
      paths =
        let
          wrapped-package = pkgs.writeShellScriptBin "teams-for-linux" ''
            exec ${pkgs.teams-for-linux}/bin/teams-for-linux --defaultURLHandler "${xdg-wrapper}" "$@"
          '';
        in
        [ wrapped-package pkgs.teams-for-linux ];
    })
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
