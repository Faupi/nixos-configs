{ config, lib, pkgs, ... }:
let
  cfg = config.services.clipboardActions;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    flatten
    unique
    getExe
    getExe'
    ;

  clipboardActionsScript = pkgs.writeShellApplication {
    name = "clipboard-actions";
    runtimeInputs = [ cfg.runtimeEnv ];
    text = ''
      WOFI_CSS=${./wofi.css}
      APP_NAME='Clipboard Actions'
      ${builtins.readFile ./main.sh}
    '';
  };
in
{
  options.services.clipboardActions = {
    enable = mkEnableOption "Klipper-like clipboard actions";

    rules = mkOption {
      default = [ ];

      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
            };

            regex = mkOption {
              type = types.str;
            };

            commands = mkOption {
              default = [ ];

              type = types.listOf (
                types.submodule {
                  options = {
                    label = mkOption {
                      type = types.str;
                    };

                    command = mkOption {
                      type = types.lines;
                    };

                    output = mkOption {
                      type = types.enum [
                        "copy"
                        "ignore"
                      ];
                    };

                    runtimeInputs = mkOption {
                      type = types.listOf types.package;
                      default = [ ];
                    };
                  };
                }
              );
            };
          };
        }
      );
    };

    jsonConfig = mkOption {
      type = types.path;
      description = "Full JSON configuration for clipboard actions. Is generated automatically from options if not defined.";
      default = (pkgs.formats.json { }).generate "clipboard-actions.json" {
        rules = map
          (rule: {
            inherit (rule) name regex;

            commands = map
              (command: {
                inherit (command)
                  label
                  command
                  output;
              })
              rule.commands;
          })
          cfg.rules;
      };
    };

    # NOTE: Can be used to test locally without rebuilds
    runtimeEnv = mkOption {
      type = types.package;
      readOnly = true;
      internal = true;

      default = pkgs.buildEnv {
        name = "clipboard-actions-runtime";
        paths = with pkgs; [
          bash
          jq
          wofi
          wl-clipboard
          libnotify
        ] ++ (unique (
          flatten (
            map
              (rule:
                flatten (
                  map (command: command.runtimeInputs)
                    rule.commands
                )
              )
              cfg.rules
          )
        ));
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.clipboard-actions = {
      Unit = {
        Description = "Clipboard Actions";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        SyslogIdentifier = "clipboard-actions";

        ExecStart = ''
          ${getExe' pkgs.wl-clipboard "wl-paste"} \
            --type text \
            --watch \
            ${getExe clipboardActionsScript} \
            ${cfg.jsonConfig}
        '';

        Restart = "always";

        RestartTriggers = [
          clipboardActionsScript
          cfg.jsonConfig
        ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
