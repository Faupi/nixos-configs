{ lib, pkgs, fop-utils, ... }:
with lib; {
  isDefault = mkDefault false;

  settings = fop-utils.recursiveMerge [
    # Startup
    {
      "app.normandy.first_run" = false;
      "doh-rollout.doneFirstRun" = true;
      "browser.eme.ui.firstContentShown" = true;
      "trailhead.firstrun.didSeeAboutWelcome" = true;
      "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;
    }

    # Telemetry
    {
      "devtools.onboarding.telemetry.logged" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.ping-centre.telemetry" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.hybridContent.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.sessions.current.clean" = true;
    }

    # Translator
    {
      "browser.translations.automaticallyPopup" = false;
      "browser.translations.neverTranslateLanguages" = "cs";
      "browser.translations.panelShown" = true;
    }

    # Extensions
    {
      "extensions.update.enabled" = false;
      "extensions.update.autoUpdateDefault" = false;
    }

    # User Agent
    {
      # Let Teams web show options for opening links in desktop app (teams-for-linux)
      # TODO: Set up an extension derivation to do this per-domain
      "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.134 Safari/537.36";
    }

    # Misc
    {
      "extensions.activeThemeID" = "default-theme@mozilla.org";
    }
  ];

  search = {
    force = true;
    default = "DuckDuckGo";
    engines = {
      "Nix Packages" = {
        urls = [{
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }];

        icon =
          "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "@np" ];
      };

      "NixOS Wiki" = {
        urls =
          [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
        iconUpdateURL = "https://nixos.wiki/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
        definedAliases = [ "@nw" ];
      };
    };
  };

  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    # TODO: Add CopyTables?
    plasma-integration
    ublock-origin-lite
    darkreader # TODO: Link config
    duckduckgo-privacy-essentials
    brandon1024-find # Regex find
  ];
}
