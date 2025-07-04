{ self
, lib
, inputs
, fop-utils
, defaultNixpkgsConfig
, ...
}:
rec {
  nixosModules = (import ./nixos/modules { inherit lib; });
  nixosConfigs = (import ./nixos/cfgs { inherit lib; });

  homeManagerModules = (import ./home-manager/modules { inherit lib; });
  homeManagerConfigs = (import ./home-manager/cfgs { inherit lib; });

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
            inherit inputs fop-utils homeManagerModules; # Do NOT pass homeManagerConfigs through here or skibidi toilet will appear in your room at 3 AM
          };
          homeArgs' = { inherit config lib pkgs; } // homeArgs; # stupid but just to make sure nixd doesn't cry about unused arguments
          fullArgs = baseArgs // homeArgs' // specialArgs;

          sharedModules = [
            homeManagerModules.mutability
            homeManagerModules.nixgl
            homeManagerModules.apparmor
            inputs.chaotic.homeManagerModules.default
          ];
          sharedGraphicalModules = [
            # "Optionated" configs
            # TODO: Import all once they're reworked
            homeManagerConfigs.shared.blender
            homeManagerConfigs.shared.discord
            homeManagerConfigs.shared.kde-plasma
            homeManagerConfigs.shared.teams
          ];

          userModules = [
            homeManagerConfigs.base.main
            homeManagerConfigs.${name}.main
          ];
          userGraphicalModules = [
            homeManagerConfigs.base.graphical
            homeManagerConfigs.${name}.graphical
          ];

          wrappedModules = builtins.map (mod: (mod fullArgs)) (
            userModules
            ++ sharedModules
            ++ extraModules # args
            ++ lib.lists.optionals graphical (
              userGraphicalModules
              ++ sharedGraphicalModules
              ++ graphicalModules # args
            )
          );
        in
        {
          imports = wrappedModules;

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
  #!region

  #region System
  mkSystem = name:
    { extraModules ? [ ]
    , extraOverlays ? [ ]
      # TODO: Set up users arg
    , targetNixpkgs ? inputs.nixpkgs
    , targetHomeManager ? inputs.home-manager
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
          nixosConfigs.base
          nixosConfigs.${name}

          targetHomeManager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.chaotic.nixosModules.default
          inputs.flake-programs-sqlite.nixosModules.programs-sqlite

          # "Optionated" configs
          # TODO: Import all once they're reworked
          nixosConfigs.shared._1password
          nixosConfigs.shared.audio
          nixosConfigs.shared.desktop-plasma6
          nixosConfigs.shared.monitor-input-switcher
        ]
        ++ extraModules;
        specialArgs = {
          inherit inputs fop-utils homeManagerModules nixosModules;
          inherit (self) homeUsers;
        };
      };
    }; #!region
}
