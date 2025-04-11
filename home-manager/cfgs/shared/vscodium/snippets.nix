{ ... }: {
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
}
