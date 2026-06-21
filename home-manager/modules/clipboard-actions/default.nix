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

  runtimeInputs =
    unique (
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
    );

  jsonConfig = (pkgs.formats.json { }).generate "clipboard-actions.json" {
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

  clipboardActionsScript = pkgs.writeShellApplication {
    name = "clipboard-actions";
    runtimeInputs = with pkgs; [
      bash
      jq
      wofi
      wl-clipboard
      libnotify
    ] ++ runtimeInputs;
    text = ''
      WOFI_CSS=${./wofi.css}
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
  };

  config = mkIf cfg.enable {
    systemd.user.services.clipboard-actions = {
      Unit = {
        Description = "Clipboard Actions";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = ''
          ${getExe' pkgs.wl-clipboard "wl-paste"} \
            --type text \
            --watch \
            ${getExe clipboardActionsScript} \
            ${jsonConfig}
        '';

        Restart = "always";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
