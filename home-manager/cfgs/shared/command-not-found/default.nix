{ config, pkgs, ... }:
let
  previewer = pkgs.substituteAll {
    src = ./previewer.zsh;
    isExecutable = true;
    inherit (pkgs) jq;
  };

  commandNotFound = pkgs.substituteAll {
    name = "command-not-found";
    dir = "bin";
    src = ./command-not-found.pl;
    isExecutable = true;
    dbPath = pkgs.programs-sqlite;
    perl = pkgs.perl.withPackages (p: [ p.DBDSQLite p.StringShellQuote ]);
    inherit (pkgs) fzf;
    inherit previewer;
  };

  zshLib = pkgs.substituteAll {
    src = ./handler.zsh;
    dbPath = pkgs.programs-sqlite;
    inherit commandNotFound;
  };
in
{
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
}
