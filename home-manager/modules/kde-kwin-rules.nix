{ config, lib, ... }:
with lib;
let
  cfg = config.programs.plasma.kwin.rules;

  ruleOpts = { name, config, options, ... }: {
    options = {
      # TODO: Add order/priority option? KWin gives higher priority to rules listed higher 
      #       - priority is currently based on alphabetical order due to native nix sorting
      # TODO: Parse some of the most used options with pretty values?

      enable = mkEnableOption "Enable rule";
      extraConfig = mkOption {
        default = { };
        type = types.attrs;
        description = "Attributes passed directly into the rule's section in the running config";
      };
    };
  };

  enabledRules = flip attrsets.filterAttrs cfg (_: rule: rule.enable);

  renderedRules = flip mapAttrs enabledRules (ruleName: rule:
    {
      Description = ruleName;
    }
    // rule.extraConfig
  );

  ruleKeys = (lib.attrsets.mapAttrsToList (name: value: name) renderedRules);
in
{
  options.programs.plasma.kwin = {
    rules = mkOption {
      default = { };
      description = "KWin Rules";
      type = with types; attrsOf (submodule ruleOpts);
    };
  };

  config = {
    programs.plasma.configFile = {
      kwinrulesrc = {
        General = {
          count = builtins.length ruleKeys;
          rules = lib.strings.concatStringsSep "," ruleKeys;
        };
      } // renderedRules;
    };
  };
}
