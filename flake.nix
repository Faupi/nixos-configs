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
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    
    flake-utils.url = "github:numtide/flake-utils";

    # Wine applications
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, jovian, plasma-manager, erosanix, ... }@inputs: with flake-utils.lib; 
  let
    lib = nixpkgs.lib;
  in
  rec {
    # TODO: Set up a builder for configurations when more are added (include base and home-manager by default, etc.)
    #       - Going to be more important when overlays come into play (Jovian!)
    #       - Forward arguments to @inputs and let systems inherit it automatically
    
    # Use the default overlay to export all packages under ./pkgs
    overlays = {
      default = final: prev:
        (import ./pkgs {
          inherit (prev) lib;
          pkgs = prev;
        });
    };

    # Export modules under ./modules as NixOS modules
    nixosModules = (import ./modules { inherit lib; });

    nixosConfigurations = {
      homeserver = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          ./cfgs/base
          ./cfgs/homeserver
          nixosModules.octoprint
        ];
      };

      deck = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          "${jovian}/modules"
          ./cfgs/base
          ./cfgs/deck { nixpkgs.overlays = [ self.overlays.default ]; }  # TODO: clean up somehow
          nixosModules.steamdeck
          nixosModules.firefox
          nixosModules._1password
          nixosModules.easyeffects
        ];
        specialArgs = { inherit plasma-manager erosanix; };
      };

      sandbox = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          home-manager.nixosModules.home-manager
          ./cfgs/base
          ./cfgs/sandbox
          nixosModules.firefox
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
        inherit lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default];
        };
      });
    }
  );
}
