{ cfg, regex, ... }:
[
  #region Quantifiers
  {
    "_name" = "Quantifiers";
    index = "regex";
    regex = regex ''[+?*|]|(\{\d+(,\d*)?\})'';
    regexFlag = "g";
    regexLimit = 1000;
    decorations = [
      {
        color = cfg.colors.regex.quantifier;
        index = 0;
      }
    ];
  } #endregion

  #region Anchors
  {
    "_name" = "Anchors";
    index = "regex";
    regex = regex ''${cfg.patterns.noEscape}(\\[bB]|[$^])'';
    regexFlag = "g";
    regexLimit = 1000;
    decorations = [
      {
        color = cfg.colors.regex.anchor;
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
    regex = regex ''${cfg.patterns.noEscape}(?<bracketL>\[\^?)(?<contents>.*?)((?<=[^\\](\\\\)*)(?<bracketR>]))'';
    regexFlag = "g";
    regexLimit = 1000;
    decorations = [
      {
        index = 0;
        backgroundColor = cfg.colors.regex.charSetBG;
      }
      {
        index = "bracketL";
        color = cfg.colors.regex.charSet;
      }
      {
        index = "bracketR";
        color = cfg.colors.regex.charSet;
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
        "color" = cfg.colors.regex.escapingChar;
        "index" = "escape";
      }
      {
        "color" = cfg.colors.regex.escapedChar;
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
            color = cfg.colors.regex.reference;
          }
        ];
      }
    ];
  } #endregion

  #region Backreferences
  {
    "_name" = "Backreferences";
    index = "regex";
    regex = regex ''${cfg.patterns.noEscape}\\(\d+|k<(?<groupName>[A-Za-z0-9_]+)>)'';
    regexFlag = "g";
    regexLimit = 1000;
    decorations = [
      {
        index = 0;
        color = cfg.colors.regex.reference;
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
    regex = regex ''${cfg.patterns.noEscape}(\.|\\[wWdDsS])'';
    regexFlag = "g";
    regexLimit = 1000;
    decorations = [
      {
        color = cfg.colors.regex.charClass;
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
    regex = regex ''${cfg.patterns.noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L4>\(.*?(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
    regexFlag = "g";
    regexLimit = 10000;
    decorations = [
      {
        index = "L1";
        backgroundColor = cfg.colors.regex.groupBGFirst;
        textDecoration = "overline ${cfg.colors.regex.groupOverline} solid 0.2em";
      }
    ];
    regexes = [
      # Nesting (background)
      {
        # Level 2
        index = "L1c";
        regex = regex ''${cfg.patterns.noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L3>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
        regexFlag = "g";
        regexLimit = 10000;
        decorations = [
          {
            index = "L1";
            backgroundColor = cfg.colors.regex.groupBGOther;
            textDecoration = "overline ${cfg.colors.regex.groupOverline} solid 0.25em";
          }
        ];
        regexes = [
          {
            # Level 3
            index = "L1c";
            regex = regex ''${cfg.patterns.noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*)(?:(?<L2>\(.*?(?<=(?:[^\\])(?:\\\\)*)(?<=(?:[^\\])(?:\\\\)*)\)).*?)*)(?<=(?:[^\\])(?:\\\\)*)\))'';
            regexFlag = "g";
            regexLimit = 10000;
            decorations = [
              {
                index = "L1";
                backgroundColor = cfg.colors.regex.groupBGOther;
                textDecoration = "overline ${cfg.colors.regex.groupOverline} solid 0.375em";
              }
            ];
            regexes = [
              {
                # Level 4
                index = "L1c";
                regex = regex ''${cfg.patterns.noEscape}(?<L1>\((?<L1c>.*?(?<=(?:[^\\])(?:\\\\)*))(?<=(?:[^\\])(?:\\\\)*)\))'';
                regexFlag = "g";
                regexLimit = 10000;
                decorations = [
                  {
                    index = "L1";
                    backgroundColor = cfg.colors.regex.groupBGOther;
                    textDecoration = "overline ${cfg.colors.regex.groupOverline} solid 0.5em";
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
        regex = regex ''${cfg.patterns.noEscape}\(\?(=|!|<=|<!|:|<(?<groupName>[A-Za-z0-9_]+)>)'';
        regexFlag = "g";
        regexLimit = 1000;
        decorations = [
          {
            index = "groupName";
            fontStyle = "italic";
          }
          {
            index = 0;
            color = cfg.colors.regex.groupExpression;
          }
        ];
      }

      # Brackets (font)
      {
        "_name" = "Brackets (font)";
        index = 0;
        regex = regex ''${cfg.patterns.noEscape}[()]'';
        regexFlag = "g";
        regexLimit = 1000;
        decorations = [
          {
            index = 0;
            color = cfg.colors.regex.groupBracket;
          }
        ];
      }
    ];
  } #endregion
]
