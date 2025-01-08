{ config, lib, pkgs, fop-utils, ... }:
let
  regex = string: string; # TODO: replace in usage with a dummy regex function from utils?

  # Make user configurations mutable
  # Depends on home-manager/modules/mutability.nix
  # https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
  mutabilityWrapper = (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
    sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
  });

  subCustomCSS = pkgs.substituteAll {
    src = ./custom-css.css;
    leafTheme = pkgs.leaf-theme-kde;
  };
  vscodium-custom-css = pkgs.vscodium.overrideAttrs (oldAttrs: {
    installPhase = (oldAttrs.installPhase or "") + ''
      substituteInPlace "$out/lib/vscode/resources/app/out/vs/code/electron-sandbox/workbench/workbench.html" \
        --replace-warn '<head>' '<head><style type="text/css">${builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.readFile subCustomCSS)}</style>'
    '';
  });
in
{
  imports = [
    mutabilityWrapper
    ./snippets.nix
  ];

  # Needed fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.liberation # #FF0
    cascadia-code # #0FF
  ];

  apparmor.profiles.vscodium.target = lib.getExe config.programs.vscode.package;

  programs = {
    vscode = fop-utils.recursiveMerge [

      #region General
      {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "vscodium-custom";
          inherit (vscodium-custom-css) pname version meta;
          paths = [ vscodium-custom-css ];
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
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            esbenp.prettier-vscode
            naumovs.color-highlight
            (extensionFromVscodeMarketplace {
              name = "RunOnSave";
              publisher = "emeraldwalk";
              version = "0.3.2";
              sha256 = "sha256-p1379+Klc4ZnKzlihmx0yCIp4wbALD3Y7PjXa2pAXgI=";
            })
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
          "window.experimentalControlOverlay" = false; # BAD (overlay is broken and unstylable)

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = false;
          "github.gitProtocol" = "ssh";

          # Tabs
          "editor.insertSpaces" = true; # Use spaces for indentation
          "editor.tabSize" = 2; # 2 spaces
          "editor.detectIndentation" = true; # If a document is set up differently, use that format

          # Misc
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "workbench.startupEditor" = "none"; # No welcome page
          "terminal.integrated.gpuAcceleration" = "on"; # NOTE: When enabled, it used to cut off input text on intel graphics
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.scrollback" = 5000; # Increase scrollback in terminal (default 1000)
          "color-highlight.matchRgbWithNoFunction" = true;
          "color-highlight.markRuler" = false;

          "workbench.editor.customLabels.enabled" = true;
          "workbench.editor.customLabels.patterns" = {
            "**/default.nix" = "\${dirname}.\${extname}";
          };
        };
      }

      #region Visuals
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "material-icon-theme";
            publisher = "PKief";
            version = "4.33.0";
            sha256 = "sha256-Rwpc5p7FOSodGa1WWrjgkexzAp8RlgZCYBXhep1G5Pk=";
          })
        ];
        userSettings = {
          # Workbench
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Default Dark Modern";
          "workbench.colorCustomizations" = {
            "statusBar.background" = "#007ACC";
            "statusBar.foreground" = "#F0F0F0";
            "statusBar.noFolderBackground" = "#222225";
            "statusBar.debuggingBackground" = "#511f1f";
          };

          # Explorer
          "explorer.fileNesting.patterns" = {
            "*.ts" = "\${capture}.js";
            "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
            "*.jsx" = "\${capture}.js";
            "*.tsx" = "\${capture}.ts";
            "*.templ" = "\${capture}_templ.go,\${capture}_templ.txt";
            "*.scss" = "\${capture}.css";
            "tsconfig.json" = "tsconfig.*.json";
            "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
            "devenv.nix" = ".devenv.flake.nix, devenv.lock, devenv.yaml";
            "flake.nix" = "flake.lock";
          };

          # Editor 
          "editor.fontFamily" = "LiterationMono Nerd Font Mono, monospace"; # #FF0
          "editor.fontLigatures" = true;
          "editor.minimap.showSlider" = "always";
          "editor.minimap.renderCharacters" = false;
          "editor.suggest.preview" = true;
          "editor.acceptSuggestionOnEnter" = "off"; # TAB is enough, good to keep enter for newline
          "workbench.editor.wrapTabs" = true;

          # Terminal
          "terminal.integrated.fontFamily" = "Cascadia Mono NF SemiBold, monospace"; # #0FF
          "terminal.integrated.fontSize" = 14;
          "terminal.integrated.minimumContrastRatio" = 1; # Disable color tweaking
        };
      }

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

      #region Nix-IDE
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "nix-ide";
            publisher = "jnoortheen";
            version = "0.3.5";
            sha256 = "sha256-hiyFZVsZkxpc2Kh0zi3NGwA/FUbetAS9khWxYesxT4s=";
          })
        ];
        userSettings =
          let
            nixfmt-path = lib.getExe (with pkgs; with unstable;
              nixpkgs-fmt);
          in
          {
            "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
            "nix.formatterPath" = nixfmt-path; # Fallback for LSP
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = lib.getExe (fop-utils.wrapPkgBinary {
              inherit pkgs;
              package = with pkgs; with unstable; nixd;
              nameAffix = "vscodium";
              variables.NIXD_FLAGS = "--semantic-tokens=true";
            });
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
      }

      #region Shell
      {
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            # Dependency for shfmt
            (editorconfig.editorconfig)

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
      }

      #region Sops
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "signageos-vscode-sops";
            publisher = "signageos";
            version = "0.9.1";
            sha256 = "sha256-b1Gp+tL5/e97xMuqkz4EvN0PxI7cJOObusEkcp+qKfM=";
          })
        ];
        userSettings = {
          "sops.binPath" = lib.getExe (with pkgs; with unstable;
            sops);
        };
      }

      #region Todo Tree
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          gruntfuggly.todo-tree
        ];
        userSettings = {
          "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];
        };
      }

      #region XML
      {
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            redhat.vscode-xml
            (extensionFromVscodeMarketplace {
              name = "xml";
              publisher = "DotJoshJohnson";
              version = "2.5.1";
              sha256 = "sha256-ZwBNvbld8P1mLcKS7iHDqzxc8T6P1C+JQy54+6E3new=";
            })
          ];
        userSettings =
          let
            lemminxBinary = lib.getExe (with pkgs; with unstable;
              lemminx);
          in
          {
            "[xml]" = { "editor.defaultFormatter" = "DotJoshJohnson.xml"; };
            "redhat.telemetry.enabled" = false;
            "xml.server.binary.path" = lemminxBinary;
            "xml.server.binary.trustedHashes" = [ (builtins.hashFile "sha256" lemminxBinary) ];
            "xml.symbols.maxItemsComputed" = 30000;
          };
      }

      #region GitLens
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          eamodio.gitlens
        ];
      }

      #region Python
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          ms-python.python
        ];
        userSettings = {
          "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
          "python.formatting.blackPath" = lib.getExe (with pkgs;
            black);
          "python.formatting.blackArgs" = [ "--line-length 120" ];
        };
      }

      #region Markdown
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "markdown-inline-preview-vscode";
            publisher = "domdomegg";
            version = "1.1.0";
            sha256 = "sha256-mi9Skn3tVJfoQaRxsOV3WRVNXhnunDOMyu/oQV2ZiWs=";
          })
        ];

        # Taken from the expansion's recommended settings
        userSettings = {
          "[markdown]" = {
            "editor.autoClosingBrackets" = "never";
            "editor.bracketPairColorization.enabled" = false;
            "editor.cursorBlinking" = "phase";
            "editor.fontFamily" = "Fira Sans";
            "editor.fontSize" = 13;
            "editor.guides.indentation" = false;
            "editor.indentSize" = "tabSize";
            "editor.insertSpaces" = false;
            "editor.lineHeight" = 1.5;
            "editor.lineNumbers" = "off";
            "editor.matchBrackets" = "never";
            "editor.padding.top" = 20;
            "editor.quickSuggestions" = { comments = false; other = false; strings = false; };
            "editor.tabSize" = 6;
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
      }

      #region Golang
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "Go";
            publisher = "golang";
            version = "0.45.0";
            sha256 = "sha256-w/74OCM1uAJzjlJ91eDoac6knD1+Imwfy6pXX9otHsY=";
          })
          (extensionFromVscodeMarketplace {
            name = "templ";
            publisher = "a-h";
            version = "0.0.29";
            sha256 = "sha256-RZ++wxL2OqBh3hiLAwKIw5QLjU/imsK7irQUHbJ/tqM=";
          })
        ];

        userSettings = {
          "[templ]" = {
            "editor.defaultFormatter" = "a-h.templ";
          };
        };
      }

      #region Hyperscript
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "vscode-hyperscript-org";
            publisher = "dz4k";
            version = "0.1.5";
            sha256 = "sha256-SrLsP4jzg8laA8LQnZ8QzlBOypVZb/e05OAW2jobyPw=";
          })
        ];
      }

      #region HTMX
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "htmx-attributes";
            publisher = "CraigRBroughton";
            version = "0.8.0";
            sha256 = "sha256-TsemPZkq2Z13/vahRaP7z206BJaCZ1TR6OVv6aeDvyk=";
          })
        ];
      }

      #region Highlight regex
      {
        extensions = with pkgs; [
          vscode-highlight-regex
        ];

        userSettings =
          let
            colorDefault = "#fff";
            colorDefaultBG = "#77F2";
            colorTag = "#666";

            colorAnchor = "#B40";
            colorQuantifier = "#1899f4";

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
          in
          {
            "highlight.regex.regexes" = [
              {
                languageIds = [ "nix" ];
                regexes = [
                  {
                    regex = regex ''(?<tag>regex)\s*\'\'(?<regex>.*?)((?<=[^\\](\\\\)*)\'\'\s*;)'';
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

                      #region Character sets
                      {
                        index = "regex";
                        regex = regex ''((?<=(^|[^\\])(\\\\)*)(?<bracketL>\[\^?))(?<contents>.*?)((?<=[^\\](\\\\)*)(?<bracketR>]))'';
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
                            index = "contents";
                            # NOTE: Turns out catching any escaped character might just be enough
                            regex = regex ''(?<others>\\[\s\S])*(?<literals>[\s\S])?'';
                            regexFlag = "g";
                            decorations = [
                              {
                                index = "literals";
                                color = colorDefault;
                              }
                            ];
                          }
                        ];
                      }

                      #region Anchors
                      {
                        index = "regex";
                        regex = regex ''((?<=(?:^|[^\\])(\\\\)*)\\[bB]|(?<=(?:^|[^\\])(\\\\)*)[$^])'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorAnchor;
                            index = 0;
                          }
                        ];
                      }

                      #region Character classes
                      {
                        index = "regex";
                        regex = regex ''((?<=(?:^|[^\\])(\\\\)*)\\[wWdDsS]|(?<=(?:^|[^\\])(\\\\)*)\.)'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorCharClass;
                            index = 0;
                          }
                        ];
                      }

                      #region Escaped characters
                      {
                        index = "regex";
                        regex = regex ''(?<escape>\\)(?<char>.)'';
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
                      }

                      #region Brackets
                      {
                        # Level 1
                        index = "regex";
                        # Note: Existing bracket formatting will break on this as it has more nesting levels than the regex itself supports ofc
                        regex = regex ''(?<=(?:^|[^\\])(?:\\\\)*)(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L4>\(.*?(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
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
                            regex = regex ''(?<=(?:^|[^\\])(?:\\\\)*)(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
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
                                regex = regex ''(?<=(?:^|[^\\])(?:\\\\)*)(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
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
                                    regex = regex ''(?<=(?:^|[^\\])(?:\\\\)*)(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*))(?<=(?:[^\\])(?:\\\\)*)\))'';
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
                            index = 0;
                            regex = regex ''(\?(=|!|<=|<!|:|<(?<groupName>[A-Za-z0-9_]+)>))'';
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
                            index = 0;
                            regex = regex ''[()]'';
                            regexFlag = "g";
                            regexLimit = 1000;
                            decorations = [
                              {
                                color = colorGroupBracket;
                                index = 0;
                              }
                            ];
                          }
                        ];
                      }

                      #region Quantifiers
                      {
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
                      }
                    ];
                  }
                ];
              }
            ];
          };
      }
    ];
  };
}
