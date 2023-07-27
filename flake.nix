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

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, jovian, plasma-manager, ... }@inputs: with flake-utils.lib; {
    # TODO: Set up a builder for configurations when more are added (include base and home-manager by default, etc.)
    #       - Going to be more important when overlays come into play (Jovian!)
    #       - Forward arguments to @inputs and let systems inherit it automatically
    
    # Use the default overlay to export all packages under ./pkgs
    overlays = {
      default = final: prev:
        (import ./pkgs {
          pkgs = prev;
        });
    };

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
          ./cfgs/deck { nixpkgs.overlays = [ self.overlays.default ]; }  # TODO: clean up somehow
          ./modules/steamdeck
          ./modules/firefox
          ./modules/1password
          ./modules/easyeffects
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
  } 
  // eachSystem [ system.x86_64-linux ] (system:
    let 
      pkgs = nixpkgs.legacyPackages.${system}; 
    in
    {
      # Other than overlay, we have packages independently declared in flake.
      packages = (import ./pkgs {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      });
    }
  );
}
