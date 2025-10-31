{ config, lib, ... }:
let
  cfg = config.flake-configs.vscodium;
in
{
  config = (lib.mkIf cfg.enable {
    programs.vscode.profiles.default.languageSnippets = {
      nix = {
        "init" = {
          prefix = "init";
          description = "Nix module boilerplate";
          body = [
            "{ ... }: {"
            "  $0"
            "}"
          ];
        };
      };
    };
  });
}
