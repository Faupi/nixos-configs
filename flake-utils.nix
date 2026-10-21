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
  nixosSharedConfigModules = {
    _1password = nixosConfigs.shared._1password;
    ananicy = nixosConfigs.shared.ananicy;
    audio = nixosConfigs.shared.audio;
    avahi = nixosConfigs.shared.avahi;
    gaming = nixosConfigs.shared.gaming;
    gaming-mice = nixosConfigs.shared.gaming-mice;
    gnome = nixosConfigs.shared.desktop-gnome;
    mango = nixosConfigs.shared.desktop-mango;
    monitor-input-switcher = nixosConfigs.shared.monitor-input-switcher;
    nix-ld = nixosConfigs.shared.nix-ld;
    plymouth = nixosConfigs.shared.plymouth;
    plasma6 = nixosConfigs.shared.desktop-plasma6;
    vr = nixosConfigs.shared.vr;
  };

  homeManagerModules = (import ./home-manager/modules { inherit lib; });
  homeManagerConfigs = (import ./home-manager/cfgs { inherit lib; });
  homeManagerSharedConfigModules = {
    blender = homeManagerConfigs.shared.blender;
    clipboard-actions = homeManagerConfigs.shared.clipboard-actions;
    dank-material-shell = homeManagerConfigs.shared.dank-material-shell;
    dolphin = homeManagerConfigs.shared.kde-dolphin;
    gnome = homeManagerConfigs.shared.gnome;
    gwenview = homeManagerConfigs.shared.gwenview;
    konsole = homeManagerConfigs.shared.konsole;
    plasma = homeManagerConfigs.shared.kde-plasma;
    teams = homeManagerConfigs.shared.teams;
    unityhub = homeManagerConfigs.shared.unityhub;
    vivaldi = homeManagerConfigs.shared.vivaldi;
    vscodium = homeManagerConfigs.shared.vscodium;
    zen = homeManagerConfigs.shared.zen;
  };

  selectSharedConfigModules = registry: configs:
    map
      (name: registry.${name} or (throw "Unknown shared configuration: ${name}"))
      (builtins.attrNames configs);

  #region Home
  mkHome = name:
    { sharedConfigs ? { }
    , extraOverlays ? [ ]
    , extraModules ? [ ]
    , specialArgs ? { }
    }: {
      "${name}" = { system }: # Wrapper for requesting different variants
        { config, lib, pkgs, ... }@homeArgs:
        let
          baseArgs = {
            inherit inputs fop-utils homeManagerModules; # Do NOT pass homeManagerConfigs through here or skibidi toilet will appear in your room at 3 AM
          };
          homeArgs' = { inherit config lib pkgs; } // homeArgs; # stupid but just to make sure nixd doesn't cry about unused arguments
          fullArgs = baseArgs // homeArgs' // specialArgs;

          userModules = [
            homeManagerConfigs.base
            homeManagerConfigs.${name}
          ];
          sharedModules = [
            homeManagerModules.mutability
            homeManagerModules.nixgl
            homeManagerModules.apparmor
            inputs.chaotic.homeManagerModules.default
          ];
          sharedConfigModules = selectSharedConfigModules homeManagerSharedConfigModules sharedConfigs;

          wrappedModules = map (mod: (mod fullArgs)) (
            userModules
            ++ sharedModules
            ++ extraModules # args
            ++ lib.lists.optionals (sharedConfigs != { }) sharedConfigModules
          );
        in
        {
          imports = wrappedModules
            ++ lib.lists.optional (sharedConfigs != { }) { flake-configs = sharedConfigs; };

          nixpkgs = defaultNixpkgsConfig system {
            extraOverlays = extraOverlays;
          };

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
        modules = [
          (homeUser (variantArgs // { inherit system; }))
        ]
        ++ extraModules;
      };
    };
  #!region

  #region System
  mkSystem = name:
    { extraModules ? [ ]
    , sharedConfigs ? { }
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
          inputs.chaotic.nixosModules.nyx-cache
          inputs.chaotic.nixosModules.nyx-overlay
          inputs.chaotic.nixosModules.nyx-registry
          inputs.flake-programs-sqlite.nixosModules.programs-sqlite

        ]
        ++ extraModules
        ++ lib.lists.optionals (sharedConfigs != { }) (
          selectSharedConfigModules nixosSharedConfigModules sharedConfigs
            ++ [{ flake-configs = sharedConfigs; }]
        );
        specialArgs = {
          inherit inputs fop-utils homeManagerModules nixosModules system;
          inherit (self) homeUsers;
        };
      };
    }; #!region
}
