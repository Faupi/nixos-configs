{ config, pkgs, lib, fop-utils, ... }:
let
  xdg-wrapper = pkgs.writeShellScript "xdg-wrapper" ''
    unset LD_LIBRARY_PATH
    exec xdg-open $@
  '';
  wrapped-teams = config.lib.nixgl.wrapPackage (
    fop-utils.wrapPkgBinary {
      inherit pkgs;
      package = pkgs.SOCIALS.teams-for-linux;
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

      libreoffice-qt
      wrapped-teams
      # TODO: Move Teams into its own module with configs and this wrapping

      (config.lib.nixgl.wrapPackage epiphany)

      corepack

      (config.lib.nixgl.wrapPackage moonlight-qt)
    ];

    file = {
      "Teams for Linux autostart" = fop-utils.makeAutostartItemLink
        pkgs
        {
          name = "teams-for-linux-autostart";
          desktopName = "Microsoft Teams for Linux";
          icon = "teams-for-linux";
          exec = "${lib.getExe wrapped-teams} --minimized";
        }
        {
          systemWide = false;
          delay = 5;
        };
    };
  };

  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    # 1Password is taken from system package manager

    firefox.profiles.masp.isDefault = true;
  };
}
