{ ... }: {
  programs.vscode.languageSnippets = {
    nix = {
      "init" = {
        prefix = "init";
        description = "Log output to console";
        body = [
          "{ ... }: {"
          "  $0"
          "}"
        ];
      };
    };
  };
}
