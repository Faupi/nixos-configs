{ config, pkgs, lib, ... }:
{
  programs.firefox = {
    package = pkgs.firefox-esr;
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
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
        };
        "addon@darkreader.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          # TODO: Add a synced configuration
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          # 1Password
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        };
      };
    };
    preferences = {
      "app.normandy.first_run" = false;  # No annoying feature showcases
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    };
  };
}
