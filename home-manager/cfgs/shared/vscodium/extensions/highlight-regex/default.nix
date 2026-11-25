{ pkgs, ... }:
let
  regex = string: string;
in
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
                } #endregion

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
                } #endregion

                #region Character sets
                # TODO: Add "range" handling (A-Z) - dash should be tagged
                # TODO: Add POSIX class handling (e.g. [:space:])
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
                } #endregion

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
                } #endregion

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
                } #endregion

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
                } #endregion

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
                } #endregion

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
                } #endregion
              ];
            }
          ];
        }
      ];
    };
}
