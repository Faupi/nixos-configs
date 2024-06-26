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
      # "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.134 Safari/537.36";
    }

    # Search
    {
      "browser.urlbar.showSearchSuggestionsFirst" = false; # Firefox suggestions (bookmarks, history, ...) on top
      "places.frecency.bookmarkVisitBonus" = 2000; # Highest priority to frequently used bookmarks
      "places.frecency.unvisitedBookmarkBonus" = 500; # Lower priority for other bookmarks (still important)
    }

    # Misc
    {
      "extensions.activeThemeID" = "default-theme@mozilla.org";
      "middlemouse.paste" = false; # Disable middle-mouse to paste, as it causes issues in apps that use the middle mouse button to navigate
      "browser.tabs.unloadOnLowMemory" = true; # NOTE: This is disabled by default, try if it works fine enabled
    }
  ];

  search = {
    force = true;
    default = "DuckDuckGo";
    engines = {
      "Nix Packages" = {
        definedAliases = [ "@np" ];
        urls = [{
          template = "https://search.nixos.org/packages?channel=unstable&type=packages&query={searchTerms}";
        }];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      };

      "NixOS Options" = {
        definedAliases = [ "@no" ];
        urls = [{
          template = "https://search.nixos.org/options?channel=unstable&type=packages&query={searchTerms}";
        }];

        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      };

      "Nix Home-manager Options" = {
        definedAliases = [ "@hm" "@hmo" ];
        urls = [{
          template = "https://home-manager-options.extranix.com/?query={searchTerms}";
        }];

        iconUpdateURL = "https://home-manager-options.extranix.com/images/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "NixOS Wiki" = {
        definedAliases = [ "@nw" ];
        urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
        iconUpdateURL = "https://nixos.wiki/favicon.png";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "Warframe Wiki" = {
        definedAliases = [ "@wf" ];
        urls = [{
          template = "https://warframe.fandom.com/wiki/Special:Search?query={searchTerms}";
        }];

        iconUpdateURL = "https://static.wikia.nocookie.net/warframe/images/4/4a/Site-favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };

      "Steam" = {
        definedAliases = [ "@s" ];
        urls = [{
          template = "https://store.steampowered.com/search/?term={searchTerms}";
        }];

        iconUpdateURL = "https://store.steampowered.com/favicon.ico";
        updateInterval = 24 * 60 * 60 * 1000; # every day
      };
    };
  };

  # https://nur.nix-community.org/repos/rycee/
  # https://nur.nix-community.org/repos/bandithedoge/
  #   (pkgs.nur.repos.bandithedoge.firefoxAddons)
  extensions =
    (with pkgs.nur.repos.rycee.firefox-addons; [
      # TODO: Add CopyTables?
      plasma-integration
      darkreader # TODO: Link config
      duckduckgo-privacy-essentials
      brandon1024-find # Regex find
      lovely-forks # Shows notable forks on GitHub

    ]) ++ (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
      github-code-folding
      github-repo-size
      material-icons-for-github
      stylus # TODO: Add styles from catppuccin

    ]);
}
