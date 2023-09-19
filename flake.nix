{
  nixConfig = {
    accept-flake-config = true;
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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

  outputs = {
    self,
    nixpkgs,
    unstable,
    flake-utils,
    home-manager,
    jovian,
    plasma-manager,
    erosanix,
    ...
  }@inputs:
  with flake-utils.lib;
  let
    lib = nixpkgs.lib;

    mkSystem = name: { extraModules ? [ ], extraOverlays ? [ ], system }: {
      "${name}" = lib.nixosSystem {
        inherit system;
        modules = [
          {
            networking.hostName = name;
            nixpkgs.overlays = [ self.overlays.default ] ++ extraOverlays;
          }
          ./cfgs/base
          ./cfgs/${name}
        ] ++ extraModules;
        specialArgs = { inherit inputs; };
      };
    };
  in
  rec {    
    # Use the default overlay to export all packages under ./pkgs
    overlays = {
      default = final: prev:
        (import ./pkgs {
          inherit (prev) lib;
          pkgs = prev;
        })
        # Custom overlays (sorry whoever has to witness this terribleness)
        // {
          vscodium-fhs-nogpu = prev.symlinkJoin {
            name = prev.vscodium-fhs.name;
            pname = prev.vscodium-fhs.pname;
            version = prev.vscodium-fhs.version;
            paths = 
            let
              vscodium-fhs-wrapped-nogpu = prev.writeShellScriptBin "codium" ''
                exec ${prev.vscodium-fhs}/bin/codium --disable-gpu "$@"
              '';
            in [
              vscodium-fhs-wrapped-nogpu
              prev.vscodium-fhs
            ];
          };
        };
    };

    # Export modules under ./modules as NixOS modules
    nixosModules = (import ./modules { inherit lib; });

    nixosConfigurations = 
      mkSystem "homeserver" {
        extraModules = [
          nixosModules.octoprint
          nixosModules.cura
        ];
        system = "x86_64-linux";
      }
      // 
      mkSystem "deck" {
        extraModules = [
          "${jovian}/modules"
          home-manager.nixosModules.home-manager
          nixosModules.desktop-plasma
          nixosModules.steamdeck
          nixosModules.firefox
          nixosModules._1password
          nixosModules.easyeffects
        ];
        extraOverlays = [
          (import "${jovian}/overlay.nix")
        ];
        system = "x86_64-linux";
      }
      // 
      mkSystem "sandbox" {
        extraModules = [
          home-manager.nixosModules.home-manager
          nixosModules.desktop-plasma
          nixosModules.firefox
        ];
        system = "x86_64-linux";
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
          overlays = [ self.overlays.default ];
        };
      });
    }
  );
}
