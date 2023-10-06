{
  # TODO list:
  # - Set up keybinds config (Language switch, screenshots?)
  # - Impermanence
  # - Vintage Story server w/ container (mods in separate repo, symlinked into it)
  # - EasyEffects symlinks
  # - Autostarts
  #   - EasyEffects system-wide (Plasma + gamescope)
  #   - 1Password Plasma (desktop item with --silent in autostart)

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

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
    nixpkgs-unstable,
    nur,
    sops-nix,
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
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
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
            # Device scale for cursor fix
              vscodium-fhs-wrapped-nogpu = prev.writeShellScriptBin "codium" ''
                exec ${prev.vscodium-fhs}/bin/codium --disable-gpu --force-device-scale-factor=1 "$@"
              '';
            in [
              vscodium-fhs-wrapped-nogpu
              prev.vscodium-fhs
            ];
          };

          vintagestory = (
            (import nixpkgs-unstable {system = prev.system; config.allowUnfree = true;}).vintagestory.overrideAttrs(oldAttrs: rec {
              version = "1.18.12";
              src = builtins.fetchTarball {
                url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                sha256 = "sha256:0lrvzshqmx916xh32c6y30idqpmfi6my6w26l3h32y7lkx26whc6";
              };
              # TODO: Decide by refresh rate hopefully - needs gamescope/desktop switch
              preFixup = oldAttrs.preFixup + ''
                makeWrapper ${prev.libstrangle}/bin/strangle $out/bin/vintagestory \
                  --prefix LD_LIBRARY_PATH : "${oldAttrs.runtimeLibs}" \
                  --add-flags 60 \
                  --add-flags ${prev.dotnet-runtime_7}/bin/dotnet \
                  --add-flags $out/share/vintagestory/Vintagestory.dll
              '';
            })
          );
        };
    };

    # Export modules under ./modules as NixOS modules
    nixosModules = (import ./modules { inherit lib; });

    nixosConfigurations = 
      mkSystem "homeserver" {
        extraModules = [
          nixosModules.octoprint
          nixosModules.cura
          nixosModules.vintagestory
        ];
        system = "x86_64-linux";
      }
      // 
      mkSystem "deck" {
        extraModules = [
          jovian.nixosModules.jovian
          nixosModules.desktop-plasma
          nixosModules.steamdeck
          nixosModules.firefox
          nixosModules._1password
          nixosModules.easyeffects
          nixosModules.vintagestory
        ];
        extraOverlays = [
          (import "${jovian}/overlay.nix")
        ];
        system = "x86_64-linux";
      }
      // 
      mkSystem "sandbox" {
        extraModules = [
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
