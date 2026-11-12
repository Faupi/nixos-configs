{ config, lib, pkgs, fop-utils, homeManagerModules, inputs, ... }@args:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types mkDefault mkForce;
  cfg = config.flake-configs.zen;

  mimeTypes = [
    "text/html"
    "text/xml"
    "application/xml"
    "application/xhtml+xml"
    "application/xhtml_xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];
in
{
  imports = [
    homeManagerModules.zen-browser
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  options.flake-configs.zen = {
    enable = mkEnableOption "Zen browser";
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
        package = mkForce null; # Using flatpak instead, so we don't want the module to manage a package. Just the profiles and configuration.
        profiles = mkDefault {
          ${cfg.firefoxProfileName} = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/${cfg.firefoxProfileName}.nix" args) // { isDefault = true; };
        };
      };

      # Flatpak config. Using flatpak configuration allows Zen to open applications properly (via xdg-open), as by default it calls GIO, which is incredibly flaky on NixOS.
      services.flatpak = {
        enable = true;
        update.onActivation = true; # REVIEW - put somewhere shared maybe

        packages = [
          "app.zen_browser.zen"
        ];

        overrides.settings = {
          "app.zen_browser.zen".Context.filesystems = [
            "${config.home.homeDirectory}/.zen"

            "/nix/store:ro" # Nix-managed extensions + configs
            "${config.home.homeDirectory}/.config/dms:ro" # Mostly for theming like matugen via DMS
          ];
        };
      };

      xdg.desktopEntries."app.zen_browser.zen" = {
        name = "Zen Browser";
        genericName = "Web Browser";
        exec = "flatpak run app.zen_browser.zen %U";
        icon = "zen";
        terminal = false;
        categories = [ "Network" "WebBrowser" ];
        mimeType = mimeTypes;
      };
    }

    (mkIf cfg.setAsDefault {
      home.sessionVariables = {
        # TODO: There's probably a better way.
        BROWSER = fop-utils.mkIfElse (config.programs.zen-browser.package != null)
          (lib.getExe config.programs.zen-browser.package)
          (pkgs.writeShellScriptBin "zen-browser" /*sh*/''
            exec flatpak run app.zen_browser.zen "$@"
          '');
      };

      xdg.mimeApps = {
        enable = lib.mkDefault true;
        defaultApplications = fop-utils.mimeDefaultsFor "zen.desktop" mimeTypes;
      };
    })
  ]);
}
