{
  # TODO list:
  # - Impermanence
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

  outputs = { self, nixpkgs, nixpkgs-unstable, nur, sops-nix, flake-utils
    , home-manager, jovian, plasma-manager, erosanix, ... }@inputs:
    with flake-utils.lib;
    let
      lib = nixpkgs.lib;

      # Helper with default nixpkgs configuration
      defaultNixpkgsConfig = system:
        { extraOverlays ? [ ], includeDefaultOverlay ? true }: {
          inherit system;
          config.allowUnfree = true;
          overlays =
            (if includeDefaultOverlay then [ self.overlays.default ] else [ ])
            ++ extraOverlays;
        };

      fop-utils = (import ./utils.nix { inherit lib; });

      nixosModules = (import ./modules { inherit lib; });

      homeManagerModules = (import ./home-manager/modules { inherit lib; });
      homeSharedConfigs = (import ./home-manager/cfgs/shared { inherit lib; });
      mkHome = name:
        { extraModules ? [ ], specialArgs ? { } }: {
          "${name}" = { config, lib, pkgs, ... }@homeArgs:
            let
              baseArgs = { inherit fop-utils; };
              fullArgs = baseArgs // homeArgs // specialArgs;
              modulesWithBase = [ homeSharedConfigs.base ] ++ extraModules;
              wrappedModules =
                builtins.map (mod: (mod fullArgs)) modulesWithBase;
              userModule = import ./home-manager/cfgs/${name}.nix fullArgs;
            in {
              imports = wrappedModules ++ [ userModule ];
              home = lib.mkDefault {
                username = name;
                homeDirectory = "/home/${name}";
                stateVersion = "23.05";
              };
            };
        };

      mkHomeConfiguration = name:
        { homeUser ? self.homeUsers.${name}, extraModules ? [ ]
        , extraOverlays ? [ ], targetNixpkgs ? nixpkgs, system }: {
          "${name}" = home-manager.lib.homeManagerConfiguration {
            pkgs = import targetNixpkgs
              (defaultNixpkgsConfig system { inherit extraOverlays; });
            modules = [ homeUser ] ++ extraModules;
          };
        };

      mkSystem = name:
        { extraModules ? [ ], extraOverlays ? [ ], system }: {
          "${name}" = lib.nixosSystem {
            inherit system;
            modules = [
              {
                networking.hostName = name;
                nixpkgs =
                  defaultNixpkgsConfig system { inherit extraOverlays; };
              }
              ./cfgs/base
              ./cfgs/${name}
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
            ] ++ extraModules;
            specialArgs = {
              inherit inputs fop-utils homeManagerModules;
              inherit (self) homeUsers;
            };
          };
        };
    in rec {
      # Use the default overlay to export all packages under ./pkgs
      overlays = {
        default = final: prev:
          let
            unstable = (import nixpkgs-unstable
              (defaultNixpkgsConfig prev.system {
                includeDefaultOverlay = false;
              }));
          in (import ./pkgs {
            inherit (prev) lib;
            pkgs = prev;
          })
          # Custom overlays (sorry whoever has to witness this terribleness)
          # TODO: Move extra overlays to separate directory
          // {
            vscodium-fhs-nogpu = let orig-vscodium = prev.vscodium-fhs;
            in prev.symlinkJoin {
              inherit (orig-vscodium) name pname version;
              paths = let
                # Device scale for cursor fix
                vscodium-fhs-wrapped-nogpu =
                  prev.writeShellScriptBin "codium" ''
                    exec ${orig-vscodium}/bin/codium --disable-gpu --force-device-scale-factor=1 "$@"
                  '';
                # Fix for home-manager building mapping to `vscodium` for some godforsaken reason
                bin-vscodium-fix = prev.writeShellScriptBin "vscodium" ''
                  exec ${vscodium-fhs-wrapped-nogpu}/bin/codium "$@"
                '';
              in [ vscodium-fhs-wrapped-nogpu bin-vscodium-fix orig-vscodium ];
            };

            vintagestory = (unstable.vintagestory.overrideAttrs (oldAttrs: rec {
              version = "1.18.12";
              src = builtins.fetchTarball {
                url =
                  "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                sha256 =
                  "sha256:0lrvzshqmx916xh32c6y30idqpmfi6my6w26l3h32y7lkx26whc6";
              };
              # TODO: Decide by refresh rate hopefully - needs gamescope/desktop switch
              preFixup = oldAttrs.preFixup + ''
                makeWrapper ${prev.libstrangle}/bin/strangle $out/bin/vintagestory \
                  --prefix LD_LIBRARY_PATH : "${oldAttrs.runtimeLibs}" \
                  --add-flags 60 \
                  --add-flags ${prev.dotnet-runtime_7}/bin/dotnet \
                  --add-flags $out/share/vintagestory/Vintagestory.dll
              '';
            }));
          };
      };

      # Base home configs compatible with NixOS configs
      homeUsers = fop-utils.recursiveMerge [

        (mkHome "faupi" {
          extraModules = [
            plasma-manager.homeManagerModules.plasma-manager
            homeManagerModules.kde-plasma
            homeManagerModules.kde-klipper
            homeManagerModules._1password

            homeSharedConfigs.kde-klipper
            homeSharedConfigs.kde-konsole
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects

          ];
        })

        (mkHome "masp" {
          extraModules = [
            plasma-manager.homeManagerModules.plasma-manager
            homeManagerModules.kde-plasma
            homeManagerModules.kde-klipper
            homeManagerModules._1password

            homeSharedConfigs.kde-klipper
            homeSharedConfigs.kde-konsole
            homeSharedConfigs.syncDesktopItems
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects

          ];
        })

      ];

      # Home manager configurations used by home-manager
      homeConfigurations = fop-utils.recursiveMerge [

        (mkHomeConfiguration "masp" { system = "x86_64-linux"; })

      ];

      # System configurations
      nixosConfigurations = fop-utils.recursiveMerge [

        (mkSystem "homeserver" {
          extraModules = [
            nixosModules.octoprint
            nixosModules.cura
            nixosModules.vintagestory
          ];
          system = "x86_64-linux";
        })

        (mkSystem "deck" {
          extraModules = [
            jovian.nixosModules.jovian
            nixosModules.desktop-plasma
            nixosModules.steamdeck
            nixosModules.firefox
            nixosModules.vintagestory
          ];
          extraOverlays = [ (import "${jovian}/overlay.nix") ];
          system = "x86_64-linux";
        })

      ];

    } // eachSystem allSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Expose extra packages from this flake
        packages = (import ./pkgs {
          inherit lib;
          pkgs = import nixpkgs (defaultNixpkgsConfig system { });
        });
      });
}
