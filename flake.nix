{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Steamdeck wrapper
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, jovian, plasma-manager }: {
    # TODO: Set up a builder for configurations when more are added (include base and home-manager by default, etc.)
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
          home-manager.nixosModules.home-manager
          "${jovian}/modules"
          ./cfgs/base
          ./cfgs/deck
          ./modules/steamdeck
          ./modules/firefox
          ./modules/1password
        ];
        specialArgs = { inherit plasma-manager; };
      };

      sandbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          ./cfgs/base
          ./cfgs/sandbox
          ./modules/firefox
        ];
      };
    };
  };
}
