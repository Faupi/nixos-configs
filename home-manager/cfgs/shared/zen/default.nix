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
    flatpak = mkEnableOption "Install Zen browser through Flatpak instead of Nix";
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

    (mkIf cfg.flatpak {
      programs.zen-browser.package = mkForce null; # Flatpak provides the binary; the module still manages profiles and configuration.

      # Flatpak config. Using flatpak configuration allows Zen to open applications properly (via xdg-open), as by default it calls GIO, which is incredibly flaky on NixOS.
      services.flatpak = {
        enable = true;

        packages = [
          "app.zen_browser.zen"
        ];

        overrides.settings = {
          "app.zen_browser.zen".Context.filesystems = [
            # Core
            "${config.home.homeDirectory}/.zen"
            "xdg-download"

            # Nix-managed extensions + configs
            "/nix/store:ro"

            # Theming
            "xdg-config/dms:ro" # Matugen via dux-shell
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"

            # Icons (downloads, etc)
            "xdg-data/icons:ro"
          ];
        };
      };
    })

    (mkIf cfg.setAsDefault {
      home.sessionVariables = {
        BROWSER = fop-utils.mkIfElse (cfg.flatpak)
          (pkgs.writeShellScriptBin "zen-browser-flatpak-shim" /*sh*/''
            exec flatpak run app.zen_browser.zen "$@"
          '')
          (lib.getExe config.programs.zen-browser.package);
      };

      xdg.mimeApps = {
        enable = lib.mkDefault true;
        defaultApplications = fop-utils.mkIfElse (cfg.flatpak)
          (fop-utils.mimeDefaultsFor "app.zen_browser.zen.desktop" mimeTypes)
          (fop-utils.mimeDefaultsFor "zen.desktop" mimeTypes);
      };
    })
  ]);
}
