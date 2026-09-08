{ config, lib, fop-utils, ... }@args:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types mkDefault;
  cfg = config.flake-configs.zen;
in
{
  options.flake-configs.zen = {
    enable = mkEnableOption "Enable Vivaldi";
    setAsDefault = mkEnableOption "Set as default browser";
    firefoxProfileName = mkOption {
      description = "Existing Firefox profile to automatically import and set as default (if present)";
      type = types.str;
      default = config.home.username;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.zen-browser = {
        enable = true;
        profiles = mkDefault {
          ${cfg.firefoxProfileName} = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/${cfg.firefoxProfileName}.nix" args) // { isDefault = true; };
        };
      };
    }

    (mkIf cfg.setAsDefault {
      home.sessionVariables = {
        BROWSER = lib.getExe config.programs.zen-browser.package;
      };

      xdg.mimeApps = {
        enable = lib.mkDefault true;
        defaultApplications = fop-utils.mimeDefaultsFor "zen.desktop" [
          "text/html"
          "text/xml"
          "application/xml"
          "application/xhtml+xml"
          "application/xhtml_xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
      };
    })
  ]);
}
