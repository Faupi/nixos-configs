{ config, pkgs, lib, fop-utils, ... }:
with lib;
let
  xdg-wrapper = pkgs.writeShellScript "xdg-wrapper" ''
    unset LD_LIBRARY_PATH
    exec xdg-open $@
  '';
  wrapped-teams = fop-utils.enableWayland {
    inherit pkgs;
    package = config.lib.nixgl.wrapPackage (
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
  };
in
{
  home = {
    packages = [
      wrapped-teams

      (pkgs.makeAutostartItem rec {
        name = "teams-for-linux";
        package = pkgs.makeDesktopItem {
          inherit name;
          desktopName = "Microsoft Teams for Linux";
          exec = "${getExe wrapped-teams} --minimized";
          icon = "teams-for-linux";
        };
      })
    ];
  };

  apparmor.profiles.teams-for-linux.target = getExe wrapped-teams;

  programs.plasma.klipper.actions =
    let
      bash = getExe pkgs.bash;
      curl = getExe pkgs.curl;
      htmlq = getExe' pkgs.htmlq "htmlq";
      grep = getExe pkgs.gnugrep;
    in
    {
      "Teams redirect" = {
        automatic = true;
        regexp = "^https:\/\/www\.google\.com\/url\?.*q=https:\/\/teams\.microsoft\.com";
        commands = {
          "Copy clean Teams link" = {
            command = "${pkgs.substituteAll {
                src = ./google-redirect.sh;
                inherit bash curl htmlq grep;
                isExecutable = true;
              }} '%s'";
            icon = "teams-for-linux";
            output = "replace";
          };
          "Open in Teams" = {
            command = "${pkgs.substituteAll {
                src = ./google-redirect.sh;
                inherit bash curl htmlq grep;
                isExecutable = true;
              }} '%s' | xargs teams-for-linux";
            icon = "teams-for-linux";
            output = "ignore";
          };
        };
      };
    };
}
