{ self
, lib
, inputs
, fop-utils
, defaultNixpkgsConfig
, ...
}:
rec {
  nixosModules = (import ./nixos/modules { inherit lib; });

  homeManagerModules = (import ./home-manager/modules { inherit lib; });
  homeSharedConfigs = (import ./home-manager/cfgs { inherit lib; });

  #region Home
  mkHome = name:
    { extraModules ? [ ]
    , graphicalModules ? [ ] # TODO: I actually hate everything about how this is done but I'm out of patience to fix this shit - hf future me :3
    , specialArgs ? { }
    }: {
      "${name}" = { graphical ? false }: # Wrapper for requesting different variants
        { config, lib, pkgs, ... }@homeArgs:
        let
          baseArgs = {
            inherit inputs fop-utils homeManagerModules; # Do NOT pass homeSharedConfigs through here or skibidi toilet will appear in your room at 3 AM
          };
          homeArgs' = { inherit config lib pkgs; } // homeArgs; # stupid but just to make sure nixd doesn't cry about unused arguments
          fullArgs = baseArgs // homeArgs' // specialArgs;

          sharedModules = [
            homeManagerModules.mutability
            homeManagerModules.nixgl
            homeManagerModules.apparmor
            inputs.chaotic.homeManagerModules.default
            homeSharedConfigs.base.main
          ]
          ++ lib.lists.optional graphical homeSharedConfigs.base.graphical;

          wrappedModules = builtins.map (mod: (mod fullArgs)) (
            sharedModules
            ++ extraModules
            ++ lib.lists.optionals graphical graphicalModules
          );

          userModule = homeSharedConfigs.${name}.main fullArgs;
          graphicalModule = homeSharedConfigs.${name}.graphical fullArgs;
        in
        {
          imports =
            wrappedModules
            ++ [ userModule ]
            ++ lib.lists.optional graphical graphicalModule;

          home = lib.mkDefault {
            username = name;
            homeDirectory = "/home/${name}";
            stateVersion = "23.05";
          };
        };
    };

  mkHomeConfiguration = name:
    { homeUser ? self.homeUsers.${name}
    , variantArgs ? { }
    , extraModules ? [ ]
    , extraOverlays ? [ ]
    , targetNixpkgs ? inputs.nixpkgs
    , targetHomeManager ? inputs.home-manager
    , system
    }: {
      "${name}" = targetHomeManager.lib.homeManagerConfiguration {
        pkgs = import targetNixpkgs (
          defaultNixpkgsConfig system {
            extraOverlays = [
              inputs.nixgl.overlay
            ]
            ++ extraOverlays;
          }
        );
        modules = [ (homeUser variantArgs) ] ++ extraModules;
      };
    };

  #region System
  mkSystem = name:
    { extraModules ? [ ]
    , extraOverlays ? [ ]
      # TODO: Set up users arg
    , targetNixpkgs ? inputs.nixpkgs-unstable
    , targetHomeManager ? inputs.home-manager-unstable
    , system
    }:
    {
      "${name}" = targetNixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            networking.hostName = name;
            nixpkgs = defaultNixpkgsConfig system { inherit extraOverlays; };
          }
          ./nixos/cfgs/base
          ./nixos/cfgs/${name}
          targetHomeManager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.chaotic.nixosModules.default
          inputs.flake-programs-sqlite.nixosModules.programs-sqlite
        ]
        ++ extraModules;
        specialArgs = {
          inherit inputs fop-utils homeManagerModules nixosModules;
          inherit (self) homeUsers;
        };
      };
    };
}
