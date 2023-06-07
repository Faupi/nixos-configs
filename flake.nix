{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      config = {
        environment.shellAliases = {
          sayhi = "echo hi";
        };
      };
    };
  };
}
