{ config, pkgs, lib, ... }:
{
  programs.firefox = {
    package = pkgs.firefox-wayland;
    enable = true;
    policies = {
      DisablePocket = true;
      DisableTelemetry = true;
      SearchEngines.Default = "DuckDuckGo";
      SearchEngines.PreventInstalls = true;
      ExtensionSettings = {
        "sponsorBlocker@ajay.app" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorBlocker@ajay.app/latest.xpi";
        };
      };
    };
    preferences = {
      "app.normandy.first_run" = false;  # No annoying feature showcases
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    };
  };
}
