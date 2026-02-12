{ config, lib, pkgs, fop-utils, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.vscodium;
  regex = string: string;

  subCustomCSS = pkgs.replaceVars ./custom-css.css {
    leafTheme = pkgs.leaf-theme-kde;
  };

  originalPkg = pkgs.vscodium;
  targetPackage = pkgs.vscodium-custom-css.override {
    vscodium = originalPkg;
    cssPath = subCustomCSS.out;
  };
  desktopName = "codium.desktop";
in
{
  imports = [
    ./mutability-wrapper.nix
    ./snippets.nix
  ];

  options.flake-configs.vscodium = {
    enable = mkEnableOption "Enable VSCodium configuration";
    setAsDefault = mkEnableOption "Set as a default editor";
    folderHandling.enable = mkEnableOption "Add directory mimetypes";
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
      # Needed fonts
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        nerd-fonts.liberation # #FF0
        cascadia-code # #0FF
      ];

      apparmor.profiles.vscodium.target = lib.getExe config.programs.vscode.package;

      programs = {
        vscode = {
          enable = true;
          package = pkgs.symlinkJoin {
            name = "vscodium-custom";
            inherit (targetPackage) pname version meta;
            paths = [ targetPackage ];
            buildInputs = with pkgs; [ makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/codium \
                --set NIXOS_OZONE_WL 1 \
                --set NIXD_FLAGS "--semantic-tokens=true" \
                --prefix PATH : ${lib.makeBinPath (with pkgs; [
                  # TODO: Add custom option for exposed packages and move wrapping there
                  sass
                
                  # Go - templ
                  go
                  templ
                  gopls
                ])}
            '';
          };
          mutableExtensionsDir = true;

          profiles.default = fop-utils.recursiveMerge [
            #region General
            {
              enableUpdateCheck = false;
              enableExtensionUpdateCheck = false;

              extensions =
                with pkgs;
                with vscode-extensions;
                with vscode-utils;
                [
                  esbenp.prettier-vscode
                  mkhl.direnv
                  (extensionFromVscodeMarketplace {
                    name = "RunOnSave";
                    publisher = "emeraldwalk";
                    version = "0.3.2";
                    sha256 = "sha256-p1379+Klc4ZnKzlihmx0yCIp4wbALD3Y7PjXa2pAXgI=";
                  })
                  (extensionFromVscodeMarketplace {
                    name = "vscode-gitweblinks";
                    publisher = "reduckted";
                    version = "2.14.0";
                    sha256 = "sha256-w+FZyve3v+WBQsNyOrxubxkk+LCU7PU6pW85QMdUXYo=";
                  })
                  (extensionFromVscodeMarketplace {
                    name = "font-viewer";
                    publisher = "adamraichu";
                    version = "1.1.1";
                    sha256 = "sha256-0T5gxxFkb+Muf65aoU4ONtEbhsqE5H5W9BhVhsqTySM=";
                  })

                  # extended-embedded-languages
                  eclairevoyant.eel
                ];

              userSettings = {
                # Updates
                "update.mode" = "none";
                "extensions.autoUpdate" = false;
                "extensions.autoCheckUpdates" = false;

                # UI
                "workbench.editor.labelFormat" = "short"; # Always show directory in tab
                "breadcrumbs.enabled" = true;
                "window.titleBarStyle" = "custom";
                "window.menuBarVisibility" = "visible";
                "workbench.activityBar.location" = "top";
                "workbench.layoutControl.enabled" = false;
                "editor.stickyScroll.enabled" = true;
                "editor.stickyScroll.maxLineCount" = 10;

                # Allow window control styling
                "window.experimentalControlOverlay" = false; # Old setting, might as well keep
                "window.controlsStyle" = "custom"; # Use custom handling through the workbench HTML

                # Git
                "git.autofetch" = false; # Disabled to avoid prompting every time while opening
                "git.confirmSync" = false;
                "git.inputValidation" = false;
                "github.gitProtocol" = "ssh";

                # Tabs
                "editor.insertSpaces" = true; # Use spaces for indentation
                "editor.tabSize" = 2; # 2 spaces
                "editor.detectIndentation" = true; # If a document is set up differently, use that format
                # Guides - show faint guides for indents and brackets
                "editor.guides.bracketPairs" = "active";
                "editor.guides.highlightActiveBracketPair" = false;
                "editor.guides.indentation" = true;

                # Misc
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
                "prettier.trailingComma" = "none";
                "editor.formatOnSave" = true;
                "editor.quickSuggestions" = {
                  # Enable completion in comments and strings - useful for paths and code references
                  "other" = "on";
                  "comments" = "on";
                  "strings" = "on";
                };
                "editor.accessibilitySupport" = "off";

                "workbench.startupEditor" = "none"; # No welcome page
                "terminal.integrated.gpuAcceleration" = "on"; # NOTE: When enabled, it used to cut off input text on intel graphics
                "terminal.integrated.defaultProfile.linux" = "zsh";
                "terminal.integrated.scrollback" = 5000; # Increase scrollback in terminal (default 1000)

                "workbench.editor.customLabels.enabled" = true;
                "workbench.editor.customLabels.patterns" = {
                  "**/default.nix" = "\${dirname}.\${extname}";
                };

                "direnv.restart.automatic" = true;

                "color-highlight.matchRgbWithNoFunction" = true;
                "color-highlight.markRuler" = false;

                "chat.commandCenter.enabled" = false; # Disable Copilot
              };
            } #!region

            #region Visuals
            {
              extensions =
                with pkgs;
                with vscode-extensions;
                with vscode-utils;
                [
                  pkief.material-icon-theme
                  naumovs.color-highlight
                  (BeardedBear.bearded-theme.overrideAttrs (old: {
                    patches = (old.patches or [ ]) ++ [
                      ./bearded-patches/brighter-font.patch
                      ./bearded-patches/custom-primary.patch
                    ];
                  }))

                  (extensionFromVscodeMarketplace {
                    name = "folder-path-color";
                    publisher = "VisbyDev";
                    version = "0.0.14";
                    sha256 = "sha256-thBwio9q7XSn49JJb73dV/YGI5zkD+UDzcttjK1X69s=";
                  })
                  (extensionFromVscodeMarketplace {
                    name = "color-picker-universal";
                    publisher = "JeronimoEkerdt";
                    version = "2.8.5";
                    sha256 = "sha256-g49sMytX07b2G0mWgd3FgqQhM2aQIbJsu1AtdRdcgq4=";
                  })
                ];

              userSettings = fop-utils.recursiveMerge [
                (builtins.fromJSON (builtins.readFile pkgs.vscode-file-nesting-config))

                {
                  # Workbench
                  "workbench.iconTheme" = "material-icon-theme";
                  "workbench.colorTheme" = "Bearded Theme Vivid Black";
                  # "workbench.colorCustomizations" = {
                  #   "statusBar.background" = "#007ACC";
                  #   "statusBar.foreground" = "#F0F0F0";
                  #   "statusBar.noFolderBackground" = "#222225";
                  #   "statusBar.debuggingBackground" = "#511f1f";
                  # };

                  # Custom overrides for file nesting patterns
                  "explorer.fileNesting.patterns" = {
                    "*.scss" = "\${capture}.css";
                    "*.templ" = "\${capture}_templ.go";
                    "devenv.nix" = ".devenv.flake.nix, devenv.lock, devenv.yaml";
                    "default.nix" = "*.nix";
                    "flake.nix" = "flake.lock, flake-*.nix";
                  };

                  # Editor 
                  "editor.fontFamily" = "LiterationMono Nerd Font Mono, monospace"; # #FF0
                  "editor.fontLigatures" = true;
                  "editor.minimap.showSlider" = "always";
                  "editor.minimap.renderCharacters" = false;
                  "editor.suggest.preview" = true;
                  "editor.acceptSuggestionOnEnter" = "off"; # TAB is enough, good to keep enter for newline
                  "workbench.editor.wrapTabs" = true;
                  "editor.cursorStyle" = "underline";
                  "editor.cursorBlinking" = "blink";
                  "editor.cursorSurroundingLines" = 15;

                  # Terminal
                  "terminal.integrated.fontFamily" = "Cascadia Mono NF SemiBold, monospace"; # #0FF
                  "terminal.integrated.fontSize" = 14;
                  "terminal.integrated.minimumContrastRatio" = 1; # Disable color tweaking

                  # Smoothing / animations
                  "editor.smoothScrolling" = true;
                  "editor.cursorSmoothCaretAnimation" = "on"; # Is a bit quirky with smooth scroll
                  "workbench.list.smoothScrolling" = true;
                  "terminal.integrated.smoothScrolling" = true;
                  # Markdown - editor scrolls preview, but preview doesn't scroll editor
                  "markdown.preview.scrollPreviewWithEditor" = true;
                  "markdown.preview.scrollEditorWithPreview" = false;
                }
              ];
            } #!region

            # Spell check - TODO: Check if it's really worth using, Nix needs a ton of specific words added
            # {
            #   extensions = with pkgs.vscode-extensions; [ streetsidesoftware.code-spell-checker ];
            #   userSettings = {
            #     "cSpell.checkOnlyEnabledFileTypes" = false; # Disable filetypes with `"cSpell.enableFiletypes": ["!filetype"]`
            #     "cSpell.showAutocompleteSuggestions" = true;
            #     "cSpell.ignorePaths" = [
            #       "package-lock.json"
            #       "node_modules"
            #       "vscode-extension"
            #       ".git/objects"
            #       ".vscode"
            #       ".vscode-insiders"
            #       "result"
            #     ];
            #     "cSpell.userWords" = [
            #       "faupi"
            #     ];
            #   };
            # }

            #region Path autocomplete
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "path-autocomplete";
                  publisher = "ionutvmi";
                  version = "1.25.0";
                  sha256 = "sha256-iz32o1znwKpbJSdrDYf+GDPC++uGvsCdUuGaQu6AWEo=";
                })
              ];
              userSettings = {
                "path-autocomplete.triggerOutsideStrings" = true;
                "path-autocomplete.enableFolderTrailingSlash" = true;
                "path-autocomplete.extensionOnImport" = true;
                "path-autocomplete.excludedItems" = {
                  "**/default.nix" = { "when" = "**/*.nix"; }; # ignore default.nix in nix files
                  "**/{.git,node_modules}" = { "when" = "**"; }; # always ignore .git and node_modules folders
                };
              };
            } #!region

            #region Nix-IDE
            {
              extensions = with pkgs.vscode-extensions; [
                jnoortheen.nix-ide

                # jeff-hykin.better-nix-syntax # When it's working with eel
              ];
              userSettings =
                let
                  nixfmt-path = lib.getExe (with pkgs;
                    nixpkgs-fmt);
                in
                {
                  "[nix]" = {
                    "editor.defaultFormatter" = "jnoortheen.nix-ide";
                    "editor.semanticHighlighting.enabled" = false;
                    "editor.stickyScroll.defaultModel" = "foldingProviderModel";
                  };
                  "nix.formatterPath" = nixfmt-path; # Fallback for LSP
                  "nix.enableLanguageServer" = true;
                  "nix.serverPath" = lib.getExe pkgs.nixd;
                  "nix.serverSettings" = {
                    "nil" = {
                      "formatting" = {
                        "command" = [ nixfmt-path ];
                      };
                      "nix" = {
                        "maxMemoryMB" = 4096;
                        "flake" = {
                          "autoArchive" = true;
                          "autoEvalInputs" = false;
                        };
                      };
                    };
                    "nixd" = {
                      "formatting" = {
                        "command" = [ nixfmt-path ];
                      };
                      "diagnostic" = {
                        "suppress" = [
                          "sema-escaping-with" # No "nested with" warnings, seems too finicky
                        ];
                      };
                      # Nixpkgs and options linking to be done per project
                    };
                  };

                  # Suppress common (semi-random) errors 
                  "nix.hiddenLanguageServerErrors" = [
                    "textDocument/definition"
                    "textDocument/documentSymbol"
                  ];
                };
            } #!region

            #region Shell
            {
              extensions =
                with pkgs;
                with vscode-extensions;
                with vscode-utils;
                [
                  editorconfig.editorconfig # Dependency for shfmt
                  timonwong.shellcheck

                  (extensionFromVscodeMarketplace {
                    name = "shfmt";
                    publisher = "mkhl";
                    version = "1.3.0";
                    sha256 = "sha256-lmhCROQfVYdBO/fC2xIAXSa3CHoKgC3BKUYCzTD+6U0=";
                  })
                ];

              userSettings = {
                "[shellscript]" = { "editor.defaultFormatter" = "mkhl.shfmt"; };
                "shfmt.executablePath" = lib.getExe (with pkgs;
                  shfmt);
                "shfmt.executableArgs" = [ "--indent" "2" ];
              };
            } #!region

            #region Sops
            {
              extensions = with pkgs.vscode-extensions; [
                signageos.signageos-vscode-sops
              ];
              userSettings = {
                "sops.binPath" = lib.getExe (with pkgs;
                  sops);
              };
            } #!region

            #region Comment Anchors
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "comment-anchors";
                  publisher = "exodiusstudios";
                  version = "1.10.4";
                  sha256 = "sha256-FvfjPpQsgCsnY1BylhLCM/qDQChf9/iTr3cKkCGfMVI=";
                })
              ];
              userSettings = {
                "commentAnchors.tagHighlights.enabled" = true;

                "commentAnchors.tags.displayInRuler" = false;
                "commentAnchors.tags.displayInGutter" = false;

                "commentAnchors.tags.matchCase" = true;
                "commentAnchors.tags.separators" = [ " - " ": " " " ];
                "commentAnchors.tags.expandSections" = true;

                "commentAnchors.tags.provideAutoCompletion" = true;
                "commentAnchors.tags.endTag" = "!";
                "commentAnchors.tags.anchors" =
                  let
                    mkAnchor = color: scope: extraProps: ({
                      highlightColor = color;
                      scope = scope;
                    } // extraProps);

                    mkRegionAnchor = extraProps: mkAnchor "#896afc" "file" ({ behavior = "region"; } // extraProps);
                  in
                  {
                    ANCHOR = mkAnchor "#A8C023" "file" { };
                    FIXME = mkAnchor "#F44336" "workspace" {
                      styleMode = "full";
                      borderStyle = "1px solid #F44336";
                      borderRadius = 2;
                      backgroundColor = "rgba(244 67 54 / 0.15)";
                    };
                    LINK = mkAnchor "#2ecc71" "file" { behavior = "link"; };
                    NOTE = mkAnchor "#FFB300" "file" { };
                    REVIEW = mkAnchor "#64DD17" "workspace" { };
                    STUB = mkAnchor "#BA68C8" "file" { };
                    TODO = mkAnchor "#3EA8FF" "workspace" {
                      styleMode = "full";
                      borderStyle = "1px dashed #3EA8FF";
                      borderRadius = 2;
                      backgroundColor = "rgba(62 168 255 / 0.15)";
                    };

                    # Use default region which is also mapped in vscode
                    SECTION = mkRegionAnchor { enabled = false; }; # NOTE: Passing all props just to stop settings.json from complaining
                    region = mkRegionAnchor { styleMode = "full"; };
                  };
              };
            } #!region

            #region XML
            {
              extensions =
                with pkgs;
                with vscode-extensions;
                [
                  redhat.vscode-xml
                  dotjoshjohnson.xml
                ];
              userSettings =
                let
                  lemminxBinary = lib.getExe (with pkgs;
                    lemminx);
                in
                {
                  "[xml]" = { "editor.defaultFormatter" = "DotJoshJohnson.xml"; };
                  "redhat.telemetry.enabled" = false;
                  "xml.server.binary.path" = lemminxBinary;
                  "xml.server.binary.trustedHashes" = [ (builtins.hashFile "sha256" lemminxBinary) ];
                  "xml.symbols.maxItemsComputed" = 30000;
                };
            } #!region

            #region Python
            {
              # NOTE: Stable because of common build issues
              extensions = with pkgs.stable.vscode-extensions; [
                ms-python.python
              ];
              userSettings = {
                "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
                "python.formatting.blackPath" = lib.getExe (with pkgs;
                  black);
                "python.formatting.blackArgs" = [ "--line-length 120" ];
              };
            } #!region

            #region Markdown
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "markdown-inline-preview-vscode";
                  publisher = "domdomegg";
                  version = "1.1.0";
                  sha256 = "sha256-mi9Skn3tVJfoQaRxsOV3WRVNXhnunDOMyu/oQV2ZiWs=";
                })
              ];

              # Taken from the expansion's recommended settings
              # TODO: Add configuration similar to vscode-file-nesting-config (json codeblock in README)
              userSettings = {
                "[markdown]" = {
                  "editor.autoClosingBrackets" = "never";
                  "editor.bracketPairColorization.enabled" = false;
                  "editor.cursorBlinking" = "phase";
                  "editor.fontFamily" = "Fira Sans";
                  "editor.fontSize" = 13;
                  "editor.guides.indentation" = false;
                  "editor.indentSize" = "tabSize";
                  "editor.insertSpaces" = true; # Formatter uses spaces anyway
                  "editor.lineHeight" = 1.5;
                  "editor.lineNumbers" = "off";
                  "editor.matchBrackets" = "never";
                  "editor.padding.top" = 20;
                  "editor.quickSuggestions" = { comments = false; other = false; strings = false; };
                  "editor.tabSize" = 3; # 3 for numbered lists (default 6)
                  "editor.wrappingStrategy" = "advanced";
                };
                "editor.tokenColorCustomizations" = {
                  "[Default Dark Modern]" = {
                    textMateRules = [
                      {
                        scope = "punctuation.definition.list.begin.markdown";
                        settings = { foreground = "#777"; };
                      }
                    ];
                  };
                };
              };
            } #!region

            #region Golang
            {
              extensions =
                with pkgs;
                with vscode-extensions;
                with vscode-utils; [
                  golang.go

                  (extensionFromVscodeMarketplace {
                    name = "templ";
                    publisher = "a-h";
                    version = "0.0.35";
                    sha256 = "sha256-WIBJorljcnoPUrQCo1eyFb6vQ5lcxV0i+QJlJdzZYE0=";
                  })
                ];

              userSettings = {
                "[templ]" = {
                  "editor.defaultFormatter" = "a-h.templ";
                };
              };
            } #!region

            #region Hyperscript
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "vscode-hyperscript-org";
                  publisher = "dz4k";
                  version = "0.1.5";
                  sha256 = "sha256-SrLsP4jzg8laA8LQnZ8QzlBOypVZb/e05OAW2jobyPw=";
                })
              ];
            } #!region

            #region HTMX
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "htmx-attributes";
                  publisher = "CraigRBroughton";
                  version = "0.8.0";
                  sha256 = "sha256-TsemPZkq2Z13/vahRaP7z206BJaCZ1TR6OVv6aeDvyk=";
                })
              ];
            } #!region

            #region TOML
            {
              extensions = with pkgs.vscode-extensions; [
                tamasfe.even-better-toml
              ];
            } #!region

            #region Link Patterns
            {
              extensions = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "pattern-links-fork";
                  publisher = "TobiasHochguertel";
                  version = "1.3.0";
                  sha256 = "sha256-Lg3Ti6YGztx9o3EFRvoha+ITrdmJU0eCkn7Wdooi+wY=";
                })
              ];

              userSettings = {
                "patternlinks.rules" = [
                  {
                    "description" = "Github stub";
                    "linkPattern" = regex ''github:([\w-]+)/([\w-]+)'';
                    "linkTarget" = "https://github.com/$1/$2";
                  }
                  {
                    "description" = "Github stub with commit/branch";
                    "linkPattern" = regex ''github:([\w-]+)/([\w-]+)/([\w-\.]+)'';
                    "linkTarget" = "https://github.com/$1/$2/tree/$3";
                  }
                  # NOTE: The order is static! Making it dynamic might require some pattern builder
                  {
                    "description" = "fetchFromGitHub";
                    "languages" = [ "nix" ];
                    "linkPattern" = regex ''fetchFromGitHub\s*\{.*?\bowner\s*=.*?\b([\w-]+).*?\brepo\s*=.*?\b([\w-]+).*?\brev\s*=.*?\b([\w-]+).*?\}'';
                    "linkPatternFlags" = "s"; # Dot matches newline
                    "linkTarget" = "https://github.com/$1/$2/tree/$3";
                  }
                  {
                    "description" = "extensionFromVscodeMarketplace";
                    "languages" = [ "nix" ];
                    "linkPattern" = regex ''extensionFromVscodeMarketplace\s*\{.*?\bname\s*=.*?\b([\w-]+).*?\bpublisher\s*=.*?\b([\w-]+).*?\}'';
                    "linkPatternFlags" = "s"; # Dot matches newline
                    "linkTarget" = "https://marketplace.visualstudio.com/items?itemName=$2.$1";
                  }
                ];
              };
            } #!region

            #region Highlight regex
            {
              extensions = with pkgs.vscode-extensions; [
                MickaelBlet.highlight-regex
              ];

              # TODO: Split to parts, add support for other languages, e.g. shell:
              #       1. Leave out nix-specific parts (main expression + nix substitions)
              #       2. Generalize the overall handling into attrsets
              #       3. Apply attrsets - nix with custom overlays, others with base or their own
              userSettings =
                let
                  colorDefault = "#fff";
                  colorDefaultBG = "#77F2";
                  colorTag = "#666";

                  colorAnchor = "#B40";
                  colorQuantifier = "#1899f4";
                  colorReference = "#ff3dff"; # Backreferences / substitions (value changes depending on external factors)

                  colorEscapingChar = "#da70d6FF";
                  colorEscapedChar = "#ffbffcff";

                  colorGroupExpression = "#0F0F";
                  colorGroupBracket = "#0B0F";
                  colorGroupBGFirst = "#00FF0020";
                  colorGroupBGOther = "#00FF0015";
                  colorGroupOverline = "#00FF0050";

                  colorCharClass = "#F90F";
                  colorCharSet = colorCharClass;
                  colorCharSetBG = "#b26b00AA";

                  noEscape = regex ''(?<=(?:^|[^\\])(?:\\\\)*)'';
                  # NOTE: Nix quote sequences can be found under https://nix.dev/manual/nix/2.24/language/syntax - `These special characters are escaped as follows`
                  # NOTE: It requires this awkward format instead of just `'''(?:['$]|\\.)` due to the highlight-regex parsing
                  nixQuoteSequences = regex ''(?<nixEscape>'''['$]|'''\\.)''; # ''', ''$, ''\*
                in
                {
                  "highlight.regex.regexes" = [
                    {
                      languageIds = [ "nix" ];
                      name = "Regular expressions";
                      # NOTE: Most regexes here will look broken, since they set up rules for their own parsing
                      regexes = [
                        {
                          "_name" = "Main regular expression";
                          regex = regex ''(?<pre>regexp?\s*=|(?<tag>regexp?))\s*(?<quote>\'\'|'|")(?<regex>(?:.*?${nixQuoteSequences}?)+?)(?<=[^\\](\\\\)*)\k<quote>'';
                          regexFlag = "g";
                          regexLimit = 1000;
                          decorations = [
                            {
                              index = "tag";
                              color = colorTag;
                            }
                            {
                              index = "regex";
                              color = colorDefault;
                              backgroundColor = colorDefaultBG;
                            }
                          ];
                          regexes = [

                            #region Quantifiers
                            {
                              "_name" = "Quantifiers";
                              index = "regex";
                              regex = regex ''[+?*|]|(\{\d+(,\d*)?\})'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  color = colorQuantifier;
                                  index = 0;
                                }
                              ];
                            } #!region

                            #region Anchors
                            {
                              "_name" = "Anchors";
                              index = "regex";
                              regex = regex ''${noEscape}(\\[bB]|[$^])'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  color = colorAnchor;
                                  index = 0;
                                }
                              ];
                            } #!region

                            #region Character sets
                            # TODO: Add "range" handling (A-Z) - dash should be tagged
                            {
                              "_name" = "Character sets";
                              index = "regex";
                              regex = regex ''${noEscape}(?<bracketL>\[\^?)(?<contents>.*?)((?<=[^\\](\\\\)*)(?<bracketR>]))'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  index = 0;
                                  backgroundColor = colorCharSetBG;
                                }
                                {
                                  index = "bracketL";
                                  color = colorCharSet;
                                }
                                {
                                  index = "bracketR";
                                  color = colorCharSet;
                                }
                              ];
                              regexes = [
                                # Exceptions for character sets
                                {
                                  "_name" = "Character set exceptions";
                                  index = "contents";
                                  # NOTE: Turns out catching any escaped character might just be enough
                                  regex = regex ''(?<escaped>\\[\s\S])?(?<literals>[^\\])?'';
                                  regexFlag = "g";
                                  decorations = [
                                    {
                                      index = "literals";
                                      color = colorDefault;
                                    }
                                  ];
                                  regexes = [
                                    {
                                      "_name" = "Backspace character";
                                      index = "escaped";
                                      regex = regex ''\\b'';
                                      regexFlag = "g";
                                      regexLimit = 1000;
                                      decorations = [
                                        {
                                          index = 0;
                                          color = colorReference;
                                        }
                                      ];
                                    }
                                  ];
                                }
                              ];
                            } #!region

                            #region Escaped characters
                            {
                              "_name" = "Escaped characters";
                              index = "regex";
                              regex = regex ''(?<escape>\\)(?<char>[^bB])'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  "color" = colorEscapingChar;
                                  "index" = "escape";
                                }
                                {
                                  "color" = colorEscapedChar;
                                  "index" = "char";
                                }
                              ];
                              regexes = [
                                {
                                  "_name" = "Specific escaped characters";
                                  index = 0;
                                  regex = regex ''\\[rtnf]'';
                                  regexFlag = "g";
                                  regexLimit = 1000;
                                  decorations = [
                                    {
                                      index = 0;
                                      color = colorReference;
                                    }
                                  ];
                                }
                              ];
                            } #!region

                            #region Backreferences
                            {
                              "_name" = "Backreferences";
                              index = "regex";
                              regex = regex ''${noEscape}\\(\d+|k<(?<groupName>[A-Za-z0-9_]+)>)'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  index = 0;
                                  color = colorReference;
                                }
                                {
                                  "index" = "groupName";
                                  "fontStyle" = "italic";
                                }
                              ];
                            } #!region

                            #region Character classes
                            {
                              "_name" = "Character classes";
                              index = "regex";
                              regex = regex ''${noEscape}(\.|\\[wWdDsS])'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  color = colorCharClass;
                                  index = 0;
                                }
                              ];
                            } #!region

                            #region Brackets
                            {
                              # Level 1
                              "_name" = "Brackets";
                              index = "regex";
                              # NOTE: Existing bracket formatting will break on this as it has more nesting levels than the regex itself supports ofc
                              regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L4>\(.*?(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                              regexFlag = "g";
                              regexLimit = 10000;
                              decorations = [
                                {
                                  index = "L1";
                                  backgroundColor = colorGroupBGFirst;
                                  textDecoration = "overline ${colorGroupOverline} solid 0.2em";
                                }
                              ];
                              regexes = [
                                # Nesting (background)
                                {
                                  # Level 2
                                  index = "L1c";
                                  regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                                  regexFlag = "g";
                                  regexLimit = 10000;
                                  decorations = [
                                    {
                                      index = "L1";
                                      backgroundColor = colorGroupBGOther;
                                      textDecoration = "overline ${colorGroupOverline} solid 0.25em";
                                    }
                                  ];
                                  regexes = [
                                    {
                                      # Level 3
                                      index = "L1c";
                                      regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
                                      regexFlag = "g";
                                      regexLimit = 10000;
                                      decorations = [
                                        {
                                          index = "L1";
                                          backgroundColor = colorGroupBGOther;
                                          textDecoration = "overline ${colorGroupOverline} solid 0.375em";
                                        }
                                      ];
                                      regexes = [
                                        {
                                          # Level 4
                                          index = "L1c";
                                          regex = regex ''${noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*))(?<=(?:[^\\])(?:\\\\)*)\))'';
                                          regexFlag = "g";
                                          regexLimit = 10000;
                                          decorations = [
                                            {
                                              index = "L1";
                                              backgroundColor = colorGroupBGOther;
                                              textDecoration = "overline ${colorGroupOverline} solid 0.5em";
                                            }
                                          ];
                                        }
                                      ];
                                    }
                                  ];
                                }

                                # Expressions (font)
                                {
                                  "_name" = "Expressions (font)";
                                  index = 0;
                                  regex = regex ''${noEscape}\(\?(=|!|<=|<!|:|<(?<groupName>[A-Za-z0-9_]+)>)'';
                                  regexFlag = "g";
                                  regexLimit = 1000;
                                  decorations = [
                                    {
                                      index = "groupName";
                                      fontStyle = "italic";
                                    }
                                    {
                                      index = 0;
                                      color = colorGroupExpression;
                                    }
                                  ];
                                }

                                # Brackets (font)
                                {
                                  "_name" = "Brackets (font)";
                                  index = 0;
                                  regex = regex ''${noEscape}[()]'';
                                  regexFlag = "g";
                                  regexLimit = 1000;
                                  decorations = [
                                    {
                                      index = 0;
                                      color = colorGroupBracket;
                                    }
                                  ];
                                }
                              ];
                            } #!region

                            #region Nix sequences
                            {
                              "_name" = "Nix sequences";
                              index = "regex";
                              # NOTE: Backslash before `{` is to break up Nix's substition pattern, otherwise it's pointless
                              regex = regex ''(${nixQuoteSequences}|(?<!\'\')\$\{.*?})'';
                              regexFlag = "g";
                              regexLimit = 1000;
                              decorations = [
                                {
                                  index = 0;
                                  color = colorReference;
                                }
                              ];
                            } #!region
                          ];
                        }
                      ];
                    }
                  ];
                };
            } #!region
          ];
        };
      };
    })

    (mkIf (cfg.enable && cfg.setAsDefault) {
      home.sessionVariables = {
        EDITOR = lib.getExe targetPackage;
        VISUAL = lib.getExe targetPackage;
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = fop-utils.mimeDefaultsFor desktopName [
          "text/plain"
        ];
      };
    })

    (mkIf (cfg.enable && cfg.folderHandling.enable) {
      xdg.dataFile."applications/${desktopName}".source = fop-utils.mkPatchedDesktopFile {
        inherit pkgs;
        inherit desktopName;
        package = targetPackage;
        mimeTypes = [ "inode/directory" ];
      };

      xdg.mimeApps = {
        enable = true;
        associations.added."inode/directory" = [ desktopName ];
      };
    })
  ];
}
