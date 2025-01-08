{ ... }: {
  programs.vscode.languageSnippets = {
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
}
