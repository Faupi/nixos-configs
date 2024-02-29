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
    inherit (config.programs.command-not-found) dbPath;
    inherit (pkgs) fzf;
    inherit previewer;
    perl = pkgs.perl.withPackages (p: [ p.DBDSQLite p.StringShellQuote ]);
  };

  zshLib = pkgs.substituteAll {
    src = ./handler.zsh;
    inherit (config.programs.command-not-found) dbPath;
    inherit commandNotFound;
  };
in
{
  home.packages = [ commandNotFound ];

  programs.zsh = {
    sessionVariables = {
      NIX_AUTO_RUN = 1; # Auto-run nix-shell when possible
    };
    initExtra = ''
      source ${zshLib}
    '';
  };
}
