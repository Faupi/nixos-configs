{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./cfgs/homeserver
      ];
    };
  };
}
