{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.command-not-found;

  previewer = pkgs.replaceVarsWith {
    src = ./previewer.zsh;
    isExecutable = true;

    replacements = {
      inherit (pkgs) jq;
    };
  };

  commandNotFound = pkgs.replaceVarsWith {
    src = ./command-not-found.pl;
    name = "command-not-found";
    dir = "bin";
    isExecutable = true;

    replacements = {
      dbPath = pkgs.programs-sqlite;
      perl = pkgs.perl.withPackages (p: [ p.DBDSQLite p.StringShellQuote ]);
      inherit (pkgs) fzf;
      inherit previewer;
    };
  };

  zshLib = pkgs.replaceVars ./handler.zsh {
    dbPath = pkgs.programs-sqlite;
    inherit commandNotFound;
  };
in
{
  options.flake-configs.command-not-found = {
    enable = mkEnableOption "custom command-not-found handler";
  };

  config = mkIf cfg.enable {
    home.packages = [ commandNotFound ];

    programs.command-not-found.enable = false; # We're using a local override with custom handling for listing packages

    programs.zsh = {
      sessionVariables = {
        NIX_AUTO_RUN = 1; # Auto-run nix-shell when possible
      };
      initContent = ''
        source ${zshLib}
      '';
    };
  };
}
