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
      "zen.workspaces.enabled" = false;
      "zen.workspaces.show-workspace-indicator" = false;
      "zen.view.use-single-toolbar" = false;
      "zen.view.sidebar-expanded" = true;
      "zen.view.sidebar-collapsed.hide-mute-button" = false; # Currently buggy, hides active playing icon too
      # TODO: Find sidebar compact mode and its switch
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
      "zen.theme.accent-color" = "#729b79";
      "middlemouse.paste" = false; # Disable middle-mouse to paste, as it causes issues in apps that use the middle mouse button to navigate
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Allows usage of custom CSS / userChrome.css
      "extensions.autoDisableScopes" = 0; # Automatically enable extensions pulled from nix

      # Make smooth scrolling more responsive
      "general.smoothScroll.msdPhysics.enabled" = false;
      "general.smoothScroll.mouseWheel" = true;
      "general.smoothScroll.mouseWheel.durationMinMS" = 80;
      "general.smoothScroll.mouseWheel.durationMaxMS" = 100;

      # Enable settings configs through JSON - needed for extensions.settings
      "extensions.webextensions.ExtensionStorageIDB.enabled" = false;
    }

    # Zen mods
    {
      "uc.private-browsing-top-bar.border-style" = "default";
      "uc.private-browsing-top-bar.color" = "default";
      "uc.private-browsing-top-bar.highlighting-style" = "gradient";
    }
  ]; #!region

  #region Search
  search =
    let
      hideEngines = engineIds: lib.attrsets.genAttrs engineIds (name: { metaData.hidden = true; });
    in
    {
      force = true;
      default = "Unduck";
      privateDefault = "Unduck";
      order = [ "Unduck" "ddg" ];

      engines = {
        "Unduck" = {
          urls = [{ template = "https://unduck.link?q=!ddg+{searchTerms}"; }]; # Default to DDG
          icon = "https://unduck.link/search.svg";
        };

        "Nix Home-manager Options" = {
          definedAliases = [ "@hm" "@hmo" ];
          urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}"; }];
          icon = "https://home-manager-options.extranix.com/images/favicon.png";
        };
      }
      # Disable defaults
      // hideEngines [
        "bing"
        "google"
        "ebay"
        "ebay-pl"
        "wikipedia"
      ];
    }; #!region

  #region Extensions
  # https://nur.nix-community.org/repos/rycee/
  # https://nur.nix-community.org/repos/bandithedoge/
  #   (pkgs.nur.repos.bandithedoge.firefoxAddons)
  # TODO: Add extension settings (extensions.settings) https://github.com/nix-community/home-manager/blob/0c0b0ac8af6ca76b1fcb514483a9bd73c18f1e8c/modules/programs/firefox/mkFirefoxModule.nix#L717-L763
  extensions.packages =
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
    ]); #!region

  #region userChrome
  userChrome =
    # TODO: Add zen mods as custom options? + Include mod preferences from above
    ''
      /*** Zen mods generated via nix ***/
      ${(lib.concatStringsSep "\n" (map (mod: ''@import url("file://${mod}");'')
        [
          "${pkgs.fetchFromGitHub {
            owner="RobotoSkunk";
            repo="zen-better-findbar";
            rev="4810a981fcf11e8587d2308b5424d92ebdf1e695";
            sha256 = "03vjj26z5229p6ilrhch0kgnn13m5mb54ap1vsl18zay5gw3lhcm";
          }}/chrome.css"

          "${pkgs.fetchFromGitHub {
            owner="xXMacMillanXx";
            repo="remove-tab-x";
            rev="d5f77b0fff5c8c29287e9968e2bddadd60046631";
            sha256 = "1w46nf2dkmhk4kxwipfij67sqfb7i3n3a083y2h8kkcm189xg2zn";
          }}/chrome.css"

          "${pkgs.fetchFromGitHub {
            owner="danm36";
            repo="zen-browser-private-browsing-toolbar-highlighting";
            rev="309c4e723e00e01fece4585e9370be082f745244";
            sha256 = "0f4zfxayx29za7jx9iizz56wfp73hkpwzyp606iqq4a6i49yx81m";
          }}/chrome.css"
        ]
      ))}
    
    ''
    +
    builtins.readFile
      (pkgs.replaceVars ./userChrome.css {
        leafTheme = pkgs.leaf-theme-kde;
      });
  #!region
}
