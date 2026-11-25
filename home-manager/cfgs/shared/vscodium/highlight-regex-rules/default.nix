{ ... }@baseArgs:
let
  regex = string: string;

  cfg = {
    colors = {
      regex = rec {
        default = "#fff";
        defaultBG = "#77F2";
        tag = "#666";

        anchor = "#B40";
        quantifier = "#1899f4";
        reference = "#ff3dff"; # Backreferences / substitions (value changes depending on external factors)

        escapingChar = "#da70d6FF";
        escapedChar = "#ffbffcff";

        groupExpression = "#0F0F";
        groupBracket = "#0B0F";
        groupBGFirst = "#00FF0020";
        groupBGOther = "#00FF0015";
        groupOverline = "#00FF0050";

        charClass = "#F90F";
        charSet = charClass;
        charSetBG = "#b26b00AA";
      };
    };

    patterns = {
      noEscape = regex ''(?<=(?:^|[^\\])(?:\\\\)*)'';
      # NOTE: Nix quote sequences can be found under https://nix.dev/manual/nix/2.24/language/syntax - `These special characters are escaped as follows`
      # NOTE: It requires this awkward format instead of just `'''(?:['$]|\\.)` due to the highlight-regex parsing
      nixQuoteSequences = regex ''(?<nixEscape>'''['$]|'''\\.)''; # ''', ''$, ''\*
    };
  };

  args = baseArgs // { inherit cfg regex; };
in
[
  {
    languageIds = [ "nix" ];
    name = "Regular expressions";
    # NOTE: Most regexes here will look broken, since they set up rules for their own parsing
    regexes = [
      {
        "_name" = "Explicit regex";
        regex = regex ''(?<pre>regexp?\s*=|(?<tag>regexp?))\s*(?<quote>\'\'|'|")(?<regex>(?:.*?${cfg.patterns.nixQuoteSequences}?)+?)(?<=[^\\](\\\\)*)\k<quote>'';
        regexFlag = "g";
        regexLimit = 1000;
        decorations = [
          {
            index = "tag";
            color = cfg.colors.regex.tag;
          }
          {
            index = "regex";
            color = cfg.colors.regex.default;
            backgroundColor = cfg.colors.regex.defaultBG;
          }
        ];
        regexes = (import ./regex.nix args) ++ [
          #region Nix sequences
          {
            "_name" = "Nix sequences";
            index = "regex";
            # NOTE: Backslash before `{` is to break up Nix's substition pattern, otherwise it's pointless
            regex = regex ''(${cfg.patterns.nixQuoteSequences}|(?<!\'\')\$\{.*?})'';
            regexFlag = "g";
            regexLimit = 1000;
            decorations = [
              {
                index = 0;
                color = cfg.colors.regex.reference;
              }
            ];
          } #endregion
        ];
      }
    ];
  }
]
