{ lib, pkgs, fop-utils, ... }:
with lib; {
  id = mkDefault 0;
  isDefault = mkDefault false;

  #region Preferences
  settings = fop-utils.recursiveMerge [
    # Startup
    {
      "app.normandy.first_run" = false;
      "doh-rollout.doneFirstRun" = true;
      "browser.eme.ui.firstContentShown" = true;
      "trailhead.firstrun.didSeeAboutWelcome" = true;
      "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;
    }

    # Updates
    {
      "app.update.auto" = false;
      "app.update.checkInstallTime" = false;
      "extensions.update.enabled" = false;
      "extensions.update.autoUpdateDefault" = false;
    }

    # Zen options
    {
      "zen.view.use-single-toolbar" = false;
      "zen.view.sidebar-expanded" = false;
      "zen.view.sidebar-collapsed.hide-mute-button" = false; # Currently buggy, hides active playing icon too
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

    # Search
    {
      "browser.urlbar.showSearchSuggestionsFirst" = false; # Firefox suggestions (bookmarks, history, ...) on top
      "places.frecency.bookmarkVisitBonus" = 2000; # Highest priority to frequently used bookmarks
      "places.frecency.unvisitedBookmarkBonus" = 500; # Lower priority for other bookmarks (still important)
    }

    # Permissions
    {
      "permissions.default.desktop-notification" = 0; # Let sites ask for notifications perms
    }

    # New tab page
    {
      "browser.newtabpage.activity-stream.weather.temperatureUnits" = "c";
      "browser.newtabpage.activity-stream.weather.display" = "detailed";
    }

    # Tab unloading
    {
      "browser.tabs.unloadOnLowMemory" = true;
      "zen.tab-unloader.enabled" = true;
      "zen.tab-unloader.timeout-minutes" = 30;
      "zen.tab-unloader.excluded-urls" = lib.concatStringsSep "," [
        "mail.google.com"
        "calendar.google.com"
      ];
    }

    # Misc
    {
      "middlemouse.paste" = false; # Disable middle-mouse to paste, as it causes issues in apps that use the middle mouse button to navigate
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Allows usage of custom CSS / userChrome.css
      "zen.workspaces.enabled" = false;
    }
  ];

  #region Search
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

  #region Extensions
  # https://nur.nix-community.org/repos/rycee/
  # https://nur.nix-community.org/repos/bandithedoge/
  #   (pkgs.nur.repos.bandithedoge.firefoxAddons)
  extensions =
    (with pkgs.nur.repos.rycee.firefox-addons; [
      onepassword-password-manager
      darkreader # TODO: Link config
      duckduckgo-privacy-essentials

      ublock-origin
      sponsorblock # TODO: Link ID thru sops
      consent-o-matic # Automatically decline cookies

      refined-github
      lovely-forks # Shows notable forks on GitHub
    ]) ++ (with pkgs.nur.repos.bandithedoge.firefoxAddons; [
      material-icons-for-github
    ]);

  userChrome =
    # TODO: Add zen mods as custom options?
    ''
      /*** Zen mods generated via nix ***/
      ${(lib.concatStringsSep "\n" (map (mod: ''@import url("file://${mod}");'')
        []
      ))}
    
    ''
    +
    builtins.readFile
      (pkgs.substituteAll {
        src = ./userChrome.css;
        leafTheme = pkgs.leaf-theme-kde;
      });
}
