{
  outputs = { self, nixpkgs }: {
    config = {
      environment.shellAliases = {
        sayhi = "echo hi";
      };
    };
  };
}
