{ config, lib, ... }:
with lib;
{
  options.programs.plasma.klipper =
    let
      commandOpts = { name, config, options, ... }: {
        options = {
          enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable command";
          };
          # TODO: Maybe remap command newline to pipe?
          command = mkOption {
            type = types.str;
          };
          icon = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
          output =
            let possibleValues = [ "ignore" "replace" "append" ];
            in mkOption {
              type = types.enum possibleValues;
              default = "ignore";
              # TODO: Replace with findFirstIndex once merged in (as of 23.05)
              apply = input:
                (if input == "ignore" then
                  0
                else if input == "replace" then
                  1
                else if input == "append" then
                  2
                else
                  null);
            };
        };
      };

      actionOpts = { name, config, options, ... }: {
        options = {
          enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable action";
          };
          automatic = mkEnableOption "Automatic check";
          regexp = mkOption { type = types.str; };
          commands = mkOption {
            default = { };
            type = with types; attrsOf (submodule commandOpts);
          };
        };
      };
    in
    {
      # General
      syncClipboards = mkOption {
        type = types.bool;
        description = "Keep the selection and clipboard the same";
        default = true;
      };
      history = {
        keep = mkOption {
          type = types.bool;
          description = "Save history across desktop sessions";
          default = false;
        };
        size = mkOption {
          type = types.int;
          description = "History size in entries";
          default = 10;
        };
        textSelection = mkOption {
          type = types.enum [ "always" "copy" ];
          description =
            "Whether text selections are saved in the clipboard history";
          default = "copy";
        };
        nontextSelection = mkOption {
          type = types.enum [ "always" "copy" "never" ];
          description =
            "Whether non-text selections (such as images) are saved in the clipboard history";
          default = "copy";
        };
      };

      # Actions menu
      actionsMenu = {
        showOnSelect = mkOption {
          type = types.bool;
          description = "Show action popup menu immediately on selection";
          default = false;
        };
        showOnHistory = mkOption {
          type = types.bool;
          description = "Show action popup menu for an item chosen from history";
          default = false;
        };
        excludeWindows = mkOption {
          type = types.listOf types.str;
          description = "Exclude automatic popup on selection on these windows";
          default = [
            "Navigator"
            "navigator:browser"
            "konqueror"
            "keditbookmarks"
            "mozilla-bin"
            "Mozilla"
            "Opera main window"
            "opera"
            "gnumeric"
            "Gnumeric"
            "Galeon"
            "kcontrol"
            "ksirc"
            "MozillaFirebird-bin"
            "firefox-bin"
            "Firefox-bin"
            "klipper"
            "Gecko"
            "gecko"
          ];
          apply = value: builtins.concatStringsSep "," value;
        };
        timeout = mkOption {
          type = types.int;
          description = "Automatic action menu time (in seconds)";
          default = 8;
        };
        trimWhitespace = mkOption {
          type = types.bool;
          description = "Trim whitespace from selection";
          default = true;
        };
        includeMIME = mkOption {
          type = types.bool;
          description = "Include MIME actions for supported applications";
          default = true;
        };
      };

      actions = mkOption {
        default = { };
        description = "Action configuration";
        type = with types; attrsOf (submodule actionOpts);
      };
    };

  config =
    let
      cfg = config.programs.plasma.klipper;

      klipperrc = {
        General = {
          SyncClipboards = cfg.syncClipboards;
          KeepClipboardContents = cfg.history.keep;
          MaxClipItems = cfg.history.size;
          IgnoreSelection = (cfg.history.textSelection == "always");
          IgnoreImages = (cfg.history.nontextSelection == "never");
          SelectionTextOnly = (cfg.history.nontextSelection == "copy");
          TimeoutForActionPopups = cfg.actionsMenu.timeout;
          URLGrabberEnabled = cfg.actionsMenu.showOnSelect;
          NoActionsForWM_CLASS = cfg.actionsMenu.excludeWindows;
        };
        Actions = {
          ReplayActionInHistory = cfg.actionsMenu.showOnHistory;
          EnableMagicMimeActions = cfg.actionsMenu.includeMIME;
          StripWhiteSpace = cfg.actionsMenu.trimWhitespace;
        };
      };

      plasmashellrc = {
        General."Number of Actions" = (builtins.length (attrsets.attrsToList cfg.actions));
      } // (attrsets.mergeAttrsList (lists.imap0
        (ac_i: ac_v:
          let
            ac_name = ac_v.name;
            ac_value = ac_v.value;
            actionSectionName = "Action_${toString ac_i}";
          in
          if ac_name
            != null then # Prevent creation of empty objects, not sure why it happened
            ({
              ${actionSectionName} = {
                # TODO: Figure out a way to get enable working (not generating this won't disable it unless the INI is wiped)
                Description = ac_name;
                Automatic = ac_value.automatic;
                Regexp = builtins.replaceStrings [ ''\'' ] [ ''\\'' ] ac_value.regexp; # Needs to be escaped again for proper handling
                "Number of commands" =
                  (builtins.length (attrsets.attrsToList ac_value.commands));
              };
            } // (attrsets.mergeAttrsList (lists.imap0
              (cmd_i: cmd_v:
                let
                  cmd_name = cmd_v.name;
                  cmd_value = cmd_v.value;
                  commandSectionNameBit = "Command_${toString cmd_i}";
                  commandSectionName = "${actionSectionName}/${commandSectionNameBit}";
                in
                {
                  ${commandSectionName} = {
                    Description = cmd_name;
                    # Keep in mind [$e] is missing -> env vars won't be substituted
                    "Commandline[$e]" = cmd_value.command;
                    Enabled = cmd_value.enable;
                    Icon = cmd_value.icon;
                    Output = cmd_value.output;
                  };
                })
              (attrsets.attrsToList ac_value.commands))))
          else
            [ ])
        (attrsets.attrsToList cfg.actions)));
    in
    {
      programs.plasma.configFile = {
        inherit klipperrc plasmashellrc;
      };
    };
}
