{
  outputs = { self, nixpkgs }: {
    # TODO: Set up a builder for configurations when more are added (include base by default, etc.)
    nixosConfigurations = {
      homeserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/homeserver
          ./modules/octoprint
        ];
      };
      deck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/deck
        ];
      };
    };
  };
}
