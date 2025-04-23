# REVIEW: Teams-for-linux might initially need `kdePackages.qtbase` available for `qtpaths` call - otherwise it takes like a minute to launch

{ options, config, pkgs, lib, fop-utils, ... }:
with lib;
let
  cfg = config.flake-configs.teams;
  klipperConfigAvailable = (attrsets.hasAttrByPath [ "programs" "plasma" "klipper" ] options);

  wrapped-teams = fop-utils.enableWayland {
    inherit pkgs;
    package = config.lib.nixgl.wrapPackage (
      fop-utils.wrapPkgBinary {
        inherit pkgs;
        package = pkgs.teams-for-linux;
        nameAffix = "xdg";
        arguments = [
          "--appIcon '${./icon/teams-light.png}'"
        ];
      }
    );
  };
in
{
  options.flake-configs.teams = {
    enable = mkEnableOption "Enable Teams for Linux";
    autoStart = {
      enable = mkEnableOption "Teams autostart";
      minimized = mkEnableOption "Start minimized";
    };
    klipperActions.enable = mkEnableOption "Klipper utilities";
  };

  config = mkMerge ([
    (mkIf cfg.enable {
      home.packages = [
        wrapped-teams
      ]
      ++ lists.optional cfg.autoStart.enable (pkgs.makeAutostartItem rec {
        name = "teams-for-linux";
        package = pkgs.makeDesktopItem {
          inherit name;
          desktopName = "Microsoft Teams for Linux";
          exec = (getExe wrapped-teams) + strings.optionalString cfg.autoStart.minimized " --minimized";
          icon = "teams-for-linux";
        };
      });

      apparmor.profiles.teams-for-linux.target = getExe wrapped-teams;
    })
  ] ++ (lists.optional klipperConfigAvailable (mkIf (cfg.enable && cfg.klipperActions.enable)
    {
      programs.plasma.klipper.actions = (
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
        }
      );
    }))
  );
}
