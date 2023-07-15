{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
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

      sandbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/sandbox
          ./modules/firefox
          ./modules/1password-gui
        ];
      };
    };
  };
}
