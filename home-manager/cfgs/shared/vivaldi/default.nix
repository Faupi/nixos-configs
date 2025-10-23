{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.vivaldi;
in
{
  options.flake-configs.vivaldi = {
    enable = mkEnableOption "Enable Vivaldi";
  };

  config = (mkIf (cfg.enable)
    {
      programs.chromium = {
        enable = true;
        package = pkgs.unstable.vivaldi.override {
          proprietaryCodecs = true;
          enableWidevine = false; # Can't fetch (?)
        };
        nativeMessagingHosts = with pkgs; [
          kdePackages.plasma-browser-integration
        ];

        extensions = [
          # Consent-O-Matic
          { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; }

          # Dark Reader
          { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; }

          # Sponsorblock
          { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }

          # DeArrow
          { id = "enamippconapkdmgfgjchkhakpfinmaj"; }

          # ProtonDB for Steam
          { id = "ngonfifpkpeefnhelnfdkficaiihklid"; }

          # 1Password
          { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }

          #== GitHub ==
          # Refined GitHub
          { id = "hlepfoohegkhhmjieoechaddaejaokhf"; }

          # Lovely Forks
          { id = "ialbpcipalajnakfondkflpkagbkdoib"; }

          # Material icons for GitHub
          { id = "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc"; }
        ];
      };

      xdg.configFile."vivaldi/policies/managed/privacy.json".text = builtins.toJSON {
        MetricsReportingEnabled = false; # Usage & crash metrics
        UrlKeyedAnonymizedDataCollectionEnabled = false; # UKM/“Make searches & browsing better”
        AlternateErrorPagesEnabled = false; # No Google “helpful” error pages
        NetworkPredictionOptions = 2; # Prefetch/prerender (“preload pages”)
        # BackgroundModeEnabled = false; # Don’t keep background process running
        EnableMediaRouter = false; # Cast/media router

        SearchSuggestEnabled = false;
        SpellCheckServiceEnabled = false; # Use local spellcheck

        SafeBrowsingProtectionLevel = 1; # 0 = off, 1 = standard (default), 2 = enhanced

        TranslateEnabled = true; # Allow manual translate but no extra prompts/pings.

        # Memory saver / tab discarding exclusions
        TabDiscardingExceptions = [
          "https://mail.google.com/*"
          "https://calendar.google.com/*"
        ];

        PrivacySandboxPromptEnabled = false;
      };

      home.activation.vivaldiPrefsOverlay =
        let
          vivaldiPrefsOverlay = {
            /* TODO: Add default search engine (Unduck)
            - Create in browser
            - Steal new data from `~/.config/vivaldi/Default/Web Data` via SQLite 
            - Write a sqlite script to add it if it's missing and mark as default
            */
            # default_search_provider_data = rec {
            #   mirrored_template_url_data = {
            #     short_name = "Unduck";
            #     keyword = "ud";
            #     url = "https://unduck.link?q=!ddg+{searchTerms}";
            #     favicon_url = "https://unduck.link/search.svg";
            #     input_encodings = [ "UTF-8" ];
            #     safe_for_autoreplace = true;
            #   };

            #   template_url_data = mirrored_template_url_data;
            #   search_field_emplate_url_data = mirrored_template_url_data;
            #   speeddials_template_url_data = mirrored_template_url_data;

            #   private_template_url_data = mirrored_template_url_data;
            #   private_search_field_template_url_data = mirrored_template_url_data;
            #   speeddials_private_template_url_data = mirrored_template_url_data;
            # };
            vivaldi = {
              address_bar = {
                extensions = {
                  hidden_extensions = [
                    "ngonfifpkpeefnhelnfdkficaiihklid"
                    "ialbpcipalajnakfondkflpkagbkdoib"
                    "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc"
                    "mdjildafknihdffpkfmmpnpoiajfjnjd"
                    "hlepfoohegkhhmjieoechaddaejaokhf"
                  ];
                };
              };
              bookmarks = {
                panel = {
                  sorting = {
                    sortField = "manually";
                    sortOrder = 1;
                  };
                };
              };
              privacy = {
                break_mode = {
                  introduction_show = false;
                };
              };
              quick_commands = {
                first_run_tip_dismissed = true;
                open_url_in_new_tab = true;
                show_extensions = false;
                show_history = false;
                show_notes = false;
                show_reading_list = false;
              };
              system = {
                show_exit_confirmation_dialog = false;
              };
              tabs = {
                active_min_size = 60;
                bar = {
                  position = 1;
                };
                confirm_closing_tabs = true;
                new_placement = 0;
                show_synced_tabs_button = false;
                show_trash_can = false;
              };
              theme = {
                schedule = {
                  o_s = {
                    # TODO: Install the funny good theme lol lmao
                    dark = "Vivaldi2";
                    light = "Vivaldi2";
                  };
                };
                simple_scrollbar = true;
              };
              toolbars = {
                navigation = [
                  "PanelToggle"
                  "PanelWidthSpacer"
                  "Back"
                  "Forward"
                  "Reload"
                  "AddressField"
                  "Spacer"
                  "Extensions"
                  "UpdateButton"
                  "ShareVivaldi"
                ];
                panel = [
                  "PanelBookmarks"
                  "PanelDownloads"
                  "PanelTranslate"
                  "PanelWindow"
                  "Divider"
                  "PanelMail"
                  "PanelContacts"
                  "PanelCalendar"
                  "PanelTasks"
                  "PanelFeeds"
                  "WEBPANEL_949d4873-deed-4168-b306-92d1848687a5"
                  "WEBPANEL_ckmam0bsw00002y5xoafpww5i"
                  "WEBPANEL_ckn7fhhqx0000hc2roo8jshm4"
                  "PanelWeb"
                  "FlexibleSpacer"
                ];
                status = [
                  "Settings"
                  "MailStatus"
                  "CalendarStatus"
                  "StatusInfo"
                  "VersionInfo"
                  "CaptureImages"
                  "TilingToggle"
                  "PageActions"
                  "Zoom"
                  "Clock"
                ];
              };
              translate = {
                enabled = true;
              };
            };
          };
        in
        (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              set -euo pipefail
              PREFDIR="$HOME/.config/vivaldi/Default"
              PREF="$PREFDIR/Preferences"
              mkdir -p "$PREFDIR"

              # Read current or fall back to {}
              if [ -f "$PREF" ]; then
                BASE="$PREF"
              else
                BASE=$(mktemp)
                echo '{}' > "$BASE"
              fi

              OVER=$(mktemp)
              cat > "$OVER" <<'JSON'
          ${builtins.toJSON vivaldiPrefsOverlay}
          JSON

              OUT=$(mktemp)
              ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$BASE" "$OVER" > "$OUT"

              mv "$OUT" "$PREF"
              chmod 600 "$PREF"
              rm -f "$OVER"
        '');
    }
  );
}
