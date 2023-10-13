{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.plasma.klipper;

  commandOpts = { name, config, options, ... }: {
    options = {
      enable = mkEnableOption { default = true; };
      # TODO: Maybe remap command newline to pipe?
      command = mkOption { type = types.str; };
      icon = mkOption { type = types.str; };
      output = mkOption {
        # TODO: Pass the function to map this to given integers (type to specific strings)
        type = types.int;
        default = 0; # TODO: Set default by available values
        # apply = "TBD";
      };
    };
  };

  actionOpts = { name, config, options, ... }: {
    options = {
      enable = mkEnableOption { default = true; };
      automatic = mkEnableOption "Automatic check";
      regexp = mkOption { type = types.str; };
      commands = mkOption {
        default = { };
        type = with types; attrsOf (submodule commandOpts);
      };
    };
  };

  klipperrc = {
    General = {
      SyncClipboards = cfg.syncClipboards;
      KeepClipboardContents = cfg.history.keep;
      MaxClipItems = cfg.history.size;
      IgnoreSelection = (cfg.history.textSelection == "always");
      IgnoreImages = (cfg.history.nontextSelection == "never");
      SelectionTextOnly = (cfg.history.nontextSelection == "copy");
    };
  };

  plasmashellrc = (concatMapAttrs (ac_name: ac_value:
    let actionSectionName = "Action_${ac_name}";
    in ({
      ${actionSectionName} =
        { # TODO: Remap names with index by parsing actions to a list and then imap0 back?
          Description = ac_name;
          Automatic = ac_value.automatic;
          Regexp = ac_value.regexp;
          "Number of commands" = (builtins.length
            (attrsets.mapAttrsToList (name: value: ac_name) ac_value.commands));
        };
    } // (concatMapAttrs (cmd_name: cmd_value: {
      "${actionSectionName}/Command_${cmd_name}" =
        { # TODO: Same with names as above
          Description = cmd_name;
          # TODO: Check if [$e] in Commandline is needed - https://github.com/KDE/kconfig/blob/master/docs/options.md
          Commandline = cmd_value.command;
          Enabled = cmd_value.enable;
          Icon = cmd_value.icon;
          Output = cmd_value.output;
        };
    })) ac_value.commands)) cfg.actions);

in {
  options.programs.plasma.klipper = {
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

    actions = mkOption {
      default = { };
      description = "Action configuration";
      type = with types; attrsOf (submodule actionOpts);
    };
  };

  config = {
    shit = builtins.abort(generators.toINI {} plasmashellrc);
    programs.plasma.configFile = {
      klipperrc = klipperrc;
      plasmashellrc = plasmashellrc;
    };
  };
}
