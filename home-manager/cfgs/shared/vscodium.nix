{ config, lib, pkgs, fop-utils, ... }:
let
  liberationFont = (pkgs.nerdfonts.override {
    fonts = [
      "LiberationMono" # #FF0 - editor
    ];
  });

  hackFont = pkgs.nerdfont-hack-braille; # #0FF - terminal

  # Make user configurations mutable
  # Depends on home-manager/modules/mutability.nix
  # https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
  mutabilityWrapper = (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
    sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
  });
in
{
  imports = [
    mutabilityWrapper
  ];

  # Needed fonts
  fonts.fontconfig.enable = true;
  home.packages = [
    liberationFont # #FF0
    hackFont # #0FF
  ];

  apparmor.profiles.vscodium.target = lib.getExe config.programs.vscode.package;

  programs = {
    vscode = fop-utils.recursiveMerge [

      #region General
      {
        enable = true;
        package = lib.mkDefault (
          fop-utils.enableWayland {
            package = with pkgs;
              vscodium;
            inherit pkgs;
          }
        );
        extensions =
          with pkgs.unstable;
          with vscode-extensions;
          with vscode-utils;
          [
            esbenp.prettier-vscode
            naumovs.color-highlight
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

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = "off";
          "github.gitProtocol" = "ssh";

          # Tabs
          "editor.insertSpaces" = true; # Use spaces for indentation
          "editor.tabSize" = 2; # 2 spaces
          "editor.detectIndentation" = true; # If a document is set up differently, use that format

          # Misc
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "terminal.integrated.gpuAcceleration" = "off"; # When enabled, it seems to cut off input text on intel
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "color-highlight.matchRgbWithNoFunction" = true;

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

          # Editor 
          "editor.fontFamily" = "${fop-utils.getFontFamily pkgs liberationFont "mono-"}, monospace"; # #FF0
          "editor.fontLigatures" = true;
          "editor.minimap.showSlider" = "always";
          "editor.minimap.renderCharacters" = false;

          # Terminal
          "terminal.integrated.fontFamily" = "${fop-utils.getFontFamily pkgs hackFont "mono"}, monospace"; # #0FF
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
            version = "0.3.1";
            sha256 = "sha256-05oMDHvFM/dTXB6T3rcDK3EiNG2T0tBN9Au9b+Bk7rI=";
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
            "nix.serverPath" = lib.getExe (with pkgs; with unstable;
              nixd);
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
        extensions = with pkgs.unstable.vscode-extensions; [
          redhat.vscode-xml
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

      #region Highlight regex
      {
        extensions = with pkgs; [
          vscode-highlight-regex
        ];

        userSettings =
          let
            regex = string: string; # TODO: replace in usage with a dummy regex function from utils? keep escape separate

            colorDefault = "#fff";
            colorDefaultBG = "#77F2";

            colorAnchor = "#B40";
            colorQuantifier = "#1899f4";

            colorEscapingChar = "#da70d6FF";
            colorEscapedChar = "#ffbffcff";

            colorGroupBGFirst = "#00FF0020";
            colorGroupBGOther = "#00FF0015";
            colorGroupExpression = "#0F0F";
            colorGroupBracket = "#0B0F";

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
                    regex = regex ''regex\s*\'\'(?<regex>.*?)((?<=[^\\](\\\\)*)\'\'\s*;)'';
                    regexFlag = "g";
                    regexLimit = 1000;
                    regexes = [

                      # Character classes
                      {
                        index = "regex";
                        regex = regex ''\\[wWdDsS]'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorCharClass;
                            index = 0;
                          }
                        ];
                      }

                      # Word boundary anchors
                      {
                        index = "regex";
                        regex = regex ''\\[bB]'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorAnchor;
                            index = 0;
                          }
                        ];
                      }

                      # Escaped characters
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

                      #region Character sets
                      {
                        index = "regex";
                        regex = regex ''((?<=(^|[^\\])(\\\\)*)\[)\^?(?<contents>.*?)((?<=[^\\](\\\\)*)])'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorDefault;
                            index = "contents";
                          }
                          {
                            backgroundColor = colorCharSetBG;
                            color = colorCharSet;
                            index = 0;
                          }
                        ];
                      }

                      #region Dot character class
                      {
                        index = "regex";
                        regex = regex ''\.'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorCharClass;
                            index = 0;
                          }
                        ];
                      }

                      #region Start/end anchors
                      {
                        index = "regex";
                        regex = regex ''[$^]'';
                        regexFlag = "g";
                        regexLimit = 1000;
                        decorations = [
                          {
                            color = colorAnchor;
                            index = 0;
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
                            backgroundColor = colorGroupBGFirst;
                            index = "L1";
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
                                backgroundColor = colorGroupBGOther;
                                index = "L1";
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
                                    backgroundColor = colorGroupBGOther;
                                    index = "L1";
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
                                        backgroundColor = colorGroupBGOther;
                                        index = "L1";
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
                            regexFlag = "gs";
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
                            regexFlag = "gs";
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
                      {
                        index = "regex";
                        regex = regex ''.*'';
                        regexFlag = "s";
                        regexLimit = 1000;
                        decorations = [
                          {
                            backgroundColor = colorDefaultBG;
                            color = colorDefault;
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
