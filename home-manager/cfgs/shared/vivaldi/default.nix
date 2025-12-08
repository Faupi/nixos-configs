# TODO: Maybe this is overdue for a cleanup (split extensions, other definitions..)

{ lib, config, pkgs, fop-utils, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge mapAttrsToList;
  inherit (builtins) fetchurl match elemAt;
  cfg = config.flake-configs.vivaldi;

  package = pkgs.vivaldi-custom-js.override {
    vivaldi = pkgs.bleeding.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = false; # Can't fetch (?)
    };
    scriptFiles = [
      ./js/sidebar-hover.js
    ];
  };

  desktopName = "vivaldi-stable.desktop";

  # Extension IDs so they don't have to be repeated
  # This could probably be a module for setting extension properties across multiple things but meh
  extensions = {
    _1Password = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
    ConsentOMatic = "mdjildafknihdffpkfmmpnpoiajfjnjd";
    DarkReader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    DeArrow = "enamippconapkdmgfgjchkhakpfinmaj";
    LovelyForks = "ialbpcipalajnakfondkflpkagbkdoib";
    MaterialIconsGH = "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc";
    ProtonDBForSteam = "ngonfifpkpeefnhelnfdkficaiihklid";
    RefinedGitHub = "hlepfoohegkhhmjieoechaddaejaokhf";
    Sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
    uBlockOrigin = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
  };
  TMDBPlayerID = "jomgiognkiagcgfhnbajhkdccmmmmphk";
in
{
  options.flake-configs.vivaldi = {
    enable = mkEnableOption "Enable Vivaldi";
    setAsDefault = mkEnableOption "Set as default browser";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.vivaldi = {
        enable = true;
        inherit package;
        nativeMessagingHosts = with pkgs; [
          kdePackages.plasma-browser-integration
        ];

        extensions = (mapAttrsToList (_name: id: { inherit id; }) extensions) ++ [
          rec {
            id = TMDBPlayerID;
            version = "1.2.1";
            crxPath = fetchurl {
              url = "https://github.com/TomasTNunes/TMDB-Player/releases/download/v${version}/tmdb_player-chromium-${version}.crx";
              sha256 = "sha256:1lgah790zn8vdv8yr3zs5vd6kyglq04jpq8k99bi7m46ra009lgg";
            };
          }
        ];

        localStorageDefaults.origins = {
          "https://s.dunkirk.sh" =
            let
              mkBang =
                { name
                , keyword
                , url
                , domain ? (elemAt (match "https?://([^/]+).*" url) 0)
                }: {
                  ${keyword} = {
                    # Schema: https://github.com/taciturnaxolotl/unduckified/blob/95f34b50ecf4918b6283c2d68e89d4de54076e01/src/bangs/hashbanggen.ts#L6-L19
                    "t" = name;
                    "s" = keyword;
                    "u" = url;
                    "d" = domain;
                    "r" = 0;
                  };
                };
            in
            {
              custom-bangs =
                (mkBang {
                  name = "Nix Home Manager Options";
                  keyword = "homeopt";
                  url = "https://home-manager-options.extranix.com/?query={{{s}}}";
                });
            };
        };
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

      home.activation =
        let
          overlayJson = path: overlayNix: (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            set -euo pipefail
            SRC="${path}"
            DIR="$(dirname "$SRC")"
            mkdir -p "$DIR"

            # Read current or fall back to {}
            if [ -f "$SRC" ]; then
              BASE="$SRC"
            else
              BASE=$(mktemp)
              echo '{}' > "$BASE"
            fi

            OVER=$(mktemp)
            cat > "$OVER" <<'JSON'
            ${builtins.toJSON overlayNix}
            JSON

            OUT=$(mktemp)
            ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$BASE" "$OVER" > "$OUT"

            mv "$OUT" "$SRC"
            chmod 600 "$SRC"
            rm -f "$OVER"
          '');
        in
        {
          vivaldiPrefsOverlay = overlayJson "$HOME/.config/vivaldi/Default/Preferences" {
            /* TODO: Add default search engine (Unduck)
            - Create in browser
            - Steal new data from `~/.config/vivaldi/Default/Web Data` via SQLite 
            - Write a sqlite script to add it if it's missing and mark as default
                */
            default_search_provider_data = rec {
              mirrored_template_url_data = {
                short_name = "Unduckify";
                keyword = "ud";
                url = "https://s.dunkirk.sh?q={searchTerms}";
                favicon_url = "https://s.dunkirk.sh?q={searchTerms}";
                safe_for_autoreplace = true;
                is_active = 1;
              };

              template_url_data = mirrored_template_url_data;
              search_field_emplate_url_data = mirrored_template_url_data;
              speeddials_template_url_data = mirrored_template_url_data;

              private_template_url_data = mirrored_template_url_data;
              private_search_field_template_url_data = mirrored_template_url_data;
              speeddials_private_template_url_data = mirrored_template_url_data;
            };
            profile = {
              default_content_setting_values = {
                autoplay = 2; # Disallow by default
              };
            };

            vivaldi = {
              # TODO: Figure out keybinds - currently due to how jq is set up it replaces the entire array
              # actions = [
              #   {
              #     COMMAND_PAGE_BACK = {
              #       # Remove backspace and Z, keep default in line with forward
              #       shortcuts = [
              #         "alt+left"
              #         "ctrl+left"
              #       ];
              #     };
              #   }
              # ];

              address_bar = {
                extensions = {
                  hidden_extensions = with extensions; [
                    ConsentOMatic
                    DeArrow
                    LovelyForks
                    MaterialIconsGH
                    ProtonDBForSteam
                    RefinedGitHub
                    Sponsorblock
                    config.programs.vivaldi.localStorageDefaults.extensionId
                    TMDBPlayerID
                  ];
                  render_in_dropdown = true;
                };
              };

              appearance = {
                css_ui_mods_directory = ./css;
              };

              bookmarks = {
                panel = {
                  sorting = {
                    sortField = "manually";
                    sortOrder = 1;
                  };
                };
              };

              mouse_gestures = {
                enabled = false;
              };

              privacy = {
                break_mode = {
                  introduction_show = false;
                };
                ad_blocker = {
                  enable_document_blocking = true; # blocking of full pages or frames
                };
                adverse_ad_block = {
                  enabled = true;
                };
                block_pings = {
                  enabled = true;
                };
              };

              panels = {
                as_overlay = {
                  enabled = true; # Floating panels over current page
                };
                position = 1; # Right
                show_toggle = false;
                translate = {
                  automatic = true; # Automatically translate selection
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
              windows = {
                show_window_close_confirmation_dialog = false;
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
                dim_hibernated = true;
              };

              theme = {
                schedule = {
                  enabled = 0;
                };
                simple_scrollbar = true;
              };
              themes = {
                current = "1cd2db6d-f31a-4ab3-8e50-2d8739809e8c";
                current_buttons = "Vivaldi5";
                prefer_custom_buttons = true;
                user = [
                  {
                    accentFromPage = false;
                    accentOnWindow = false;
                    accentSaturationLimit = { };
                    alpha = 1;
                    backgroundImage = "";
                    backgroundPosition = "stretch";
                    blur = 0;
                    colorAccentBg = "#12161c";
                    colorBg = "#010409";
                    colorFg = "#dadee2";
                    colorHighlightBg = "#196be6";
                    colorWindowBg = "#161b22";
                    contrast = 1;
                    dimBlurred = false;
                    engineVersion = 1;
                    id = "1cd2db6d-f31a-4ab3-8e50-2d8739809e8c";
                    name = "Github Darkiey - Faupi edit";
                    preferSystemAccent = false;
                    radius = 8;
                    simpleScrollbar = true;
                    transparencyTabBar = false;
                    transparencyTabs = true; # Transparent background on inactive tabs
                    url = "https://themes.vivaldi.net/themes/NOb71K16v1g/status.json";
                    version = 5;
                  }
                ];
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
                ];
                panel = [
                  "PanelBookmarks"
                  "PanelDownloads"
                  "PanelTranslate"
                  "PanelWindow"
                  "Divider"
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
                tabbar_after = [
                  "NewTab"
                  "FlexibleSpacer"
                ];
              };

              translate = {
                enabled = true;
                target_language = "en";
              };
            };

            extensions = {
              settings = {
                "${extensions._1Password}" = {
                  incognito = true;
                };
              };
            };
          };

          # Block trackers and ads
          vivaldiAdBlockOverlay = overlayJson "$HOME/.config/vivaldi/Default/AdBlockState" {
            ad-blocking-rules = {
              exceptions-type = 1;
            };
            tracking-rules = {
              exceptions-type = 1;
            };
          };

          vivaldiLocalStateOverlay = overlayJson "$HOME/.config/vivaldi/Default/Local State" {
            browser = {
              enabled_labs_experiments = [
                "vivaldi-css-mods@1" # Enable custom CSS
                "enable-webrtc-allow-input-volume-adjustment@2" # Disable auto gain
              ];
              first_run_finished = true;
            };
          };
        };
    }

    (mkIf cfg.setAsDefault {
      home.sessionVariables = {
        BROWSER = lib.getExe package;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = fop-utils.mimeDefaultsFor desktopName [
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
