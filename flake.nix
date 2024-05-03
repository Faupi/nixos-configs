{
  # TODO list:
  # - Actually resolve TODO lists (:
  # - Impermanence
  # - Switch default stable to default unstable for same lib across all systems - pkgs should have a stable overlay

  #region Inputs
  inputs = rec {
    # Base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    # Groups
    group-socials = nixpkgs-unstable;
    group-browsers = nixpkgs-unstable;

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager-unstable";
      };
    };

    # Steamdeck wrappers
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Wine applications
    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:guibou/nixGL";

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Bleeding edge packages with caches (e.g. Jovian Deck kernel)
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
      inputs.jovian.follows = "jovian";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nur
    , group-socials
    , group-browsers
    , sops-nix
    , flake-utils
    , home-manager
    , home-manager-unstable
    , jovian
    , plasma-manager
    , erosanix
    , nixgl
    , spicetify-nix
    , chaotic
    , nix-gaming
    , ...
    }@inputs:
    let
      lib = nixpkgs-unstable.lib;
    in
    with lib;
    let
      #region Helpers
      # Helper with default nixpkgs configuration
      defaultNixpkgsConfig = system:
        { extraOverlays ? [ ]
        , includeDefaultOverlay ? true
        , includeSharedOverlay ? true
        }: {
          inherit system;
          config.allowUnfree = true;
          overlays =
            [ self.overlays.nur ]
            ++ extraOverlays
            ++ lists.optional includeDefaultOverlay self.overlays.default
            ++ lists.optional includeSharedOverlay self.overlays.shared;
        };

      fop-utils = (import ./utils.nix { inherit lib; });

      nixosModules = (import ./modules { inherit lib; });

      homeManagerModules = (import ./home-manager/modules { inherit lib; });
      homeSharedConfigs = (import ./home-manager/cfgs/shared { inherit lib; });
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
              fullArgs = baseArgs // homeArgs // specialArgs;

              sharedModules = [
                homeManagerModules.mutability
                homeManagerModules.nixgl
                chaotic.homeManagerModules.default
                homeSharedConfigs.base
              ]
              ++ lists.optional graphical homeSharedConfigs.base-graphical;

              wrappedModules = builtins.map (mod: (mod fullArgs)) (
                sharedModules
                ++ extraModules
                ++ lists.optionals graphical graphicalModules
              );

              userModule = import ./home-manager/cfgs/${name} fullArgs;
              graphicalModule = import ./home-manager/cfgs/${name}/graphical fullArgs;
            in
            {
              imports =
                wrappedModules
                ++ [ userModule ]
                ++ lists.optional graphical graphicalModule;

              home = mkDefault {
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
        , targetNixpkgs ? nixpkgs
        , targetHomeManager ? home-manager
        , system
        }: {
          "${name}" = targetHomeManager.lib.homeManagerConfiguration {
            pkgs = import targetNixpkgs (
              defaultNixpkgsConfig system {
                extraOverlays = [
                  nixgl.overlay
                ]
                ++ extraOverlays;
              }
            );
            modules = [ (homeUser variantArgs) ] ++ extraModules;
          };
        };

      mkSystem = name:
        { extraModules ? [ ]
        , extraOverlays ? [ ]
          # TODO: Set up users arg
        , targetNixpkgs ? nixpkgs-unstable
        , targetHomeManager ? home-manager-unstable
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
              ./cfgs/base
              ./cfgs/${name}
              targetHomeManager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              chaotic.nixosModules.default
            ]
            ++ extraModules;
            specialArgs = {
              inherit inputs fop-utils homeManagerModules homeSharedConfigs nixosModules;
              inherit (self) homeUsers;
            };
          };
        };
    in
    {
      #region Overlays
      overlays = {
        # Local custom packages
        default = final: prev: (
          import ./pkgs {
            inherit (prev) lib;
            pkgs = prev;
          }
        );

        # NUR - Nix user repositories
        nur = final: prev: (
          {
            # Usage: pkgs.nur.repos.author.package
            nur = import nur {
              nurpkgs = prev;
              pkgs = prev;
            };
          }
        );

        # Shared between all systems
        shared = final: prev:
          let
            importDefault = flake: (import flake
              (defaultNixpkgsConfig prev.system {
                includeDefaultOverlay = true;
                includeSharedOverlay = false;
              }));

            stable = importDefault nixpkgs;
            unstable = importDefault nixpkgs-unstable;
          in
          fop-utils.recursiveMerge [

            # Expose branches
            {
              inherit stable unstable; # TODO: This is awful for building, actually.
            }

            # Spicetify
            {
              spicetify-extras = spicetify-nix.packages.${prev.system}.default;
            }

            # Groups
            {
              SOCIALS =
                let
                  pkgs = importDefault group-socials;
                in
                {
                  inherit (pkgs) vesktop telegram-desktop spotify;

                  # Enable link handling for Teams
                  teams-for-linux = (pkgs.teams-for-linux.overrideAttrs
                    (oldAttrs: {
                      meta.mainProgram = "teams-for-linux"; # Bandaid for lib.getExe complaining
                      desktopItems = [
                        (prev.makeDesktopItem {
                          name = oldAttrs.pname;
                          exec = "${oldAttrs.pname} %U";
                          icon = oldAttrs.pname;
                          desktopName = "Microsoft Teams for Linux";
                          comment = oldAttrs.meta.description;
                          categories = [ "Network" "InstantMessaging" "Chat" ];
                          mimeTypes = [ "x-scheme-handler/msteams" ];
                        })
                      ];
                    }));
                };

              BROWSERS = {
                inherit (importDefault group-browsers)
                  firefox ungoogled-chromium epiphany;
                inherit (chaotic.packages.${prev.system})
                  firedragon; # TODO: Remove Chaotic once Firedragon is bundled in nixpkgs
                # TODO: If moving to Firedragon, figure out a way to reuse the home-manager firefox module for config
              };
            }

            # Custom overlays (sorry whoever has to witness this terribleness)
            # TODO: Move extra overlays to separate directory
            {
              vintagestory = (unstable.vintagestory.overrideAttrs
                (oldAttrs: rec {
                  version = "1.18.12";
                  src = builtins.fetchTarball {
                    url =
                      "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                    sha256 =
                      "sha256:0lrvzshqmx916xh32c6y30idqpmfi6my6w26l3h32y7lkx26whc6";
                  };
                  # TODO: Decide by refresh rate hopefully - needs gamescope/desktop switch
                  preFixup = (oldAttrs.preFixup or "") + ''
                    makeWrapper ${prev.libstrangle}/bin/strangle $out/bin/vintagestory \
                      --prefix LD_LIBRARY_PATH : "${oldAttrs.runtimeLibs}" \
                      --add-flags 60 \
                      --add-flags ${prev.dotnet-runtime_7}/bin/dotnet \
                      --add-flags $out/share/vintagestory/Vintagestory.dll
                  '';
                }));
            }
          ];

      };

      #region Users
      # Base home configs compatible with NixOS configs
      # TODO: Add custom check for homeUsers
      # TODO: Make configs automatically require their needed modules (spicetify, plasma, etc.)
      homeUsers = fop-utils.recursiveMerge [
        (mkHome "faupi" {
          extraModules = [ ];
          graphicalModules = [
            plasma-manager.homeManagerModules.plasma-manager
            homeManagerModules.kde-klipper
            homeManagerModules.kde-kwin-rules
            spicetify-nix.homeManagerModule

            homeSharedConfigs.kde-plasma
            homeSharedConfigs.kde-klipper
            homeSharedConfigs.kde-konsole
            homeSharedConfigs.kde-html-wallpaper
            homeSharedConfigs.kde-kwin-rules
            homeSharedConfigs.maliit-keyboard
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects
            homeSharedConfigs.firefox
            homeSharedConfigs.cura
            homeSharedConfigs.spicetify
            homeSharedConfigs.vesktop
          ];
        })

        (mkHome "masp" {
          extraModules = [ ];
          graphicalModules = [
            plasma-manager.homeManagerModules.plasma-manager
            homeManagerModules.kde-klipper
            homeManagerModules.kde-kwin-rules
            spicetify-nix.homeManagerModule

            homeSharedConfigs.syncDesktopItems
            homeSharedConfigs.kde-plasma
            homeSharedConfigs.kde-klipper
            homeSharedConfigs.kde-konsole
            homeSharedConfigs.kde-kwin-rules
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects
            homeSharedConfigs.firefox
            homeSharedConfigs.spicetify
            homeSharedConfigs.teams
          ];
        })

        # TODO: Add argument for loading from directory and remove cura dir once left out
        (mkHome "cura" {
          extraModules = [ ];
          graphicalModules = [
            homeSharedConfigs.cura
          ];
        })
      ];

      #region Homes
      # Home manager configurations used by home-manager
      homeConfigurations = fop-utils.recursiveMerge [
        (mkHomeConfiguration "masp" {
          system = "x86_64-linux";
          variantArgs = { graphical = true; };
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            {
              nixGLPackage = "intel";
              programs.plasma.launcherIcon = "start-here-kubuntu";
            }
            homeSharedConfigs.touchegg # X11, no native touchpad gestures
          ];
        })
      ];

      #region Systems
      # System configurations
      nixosConfigurations = fop-utils.recursiveMerge [
        (mkSystem "homeserver" {
          system = "x86_64-linux";
          # TODO: Split off most configurations similar to home-manager?
          extraModules = [
            nixosModules.service-containers
            nixosModules.octoprint
            nixosModules.cura
            nixosModules.vintagestory
          ];
        })

        (mkSystem "deck" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            jovian.nixosModules.jovian # NOTE: Imports overlays too
            nixosModules.desktop-plasma6
            nixosModules.steamdeck
            nixosModules._1password
            nixosModules.vintagestory
          ];
        })

        (mkSystem "go" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            jovian.nixosModules.jovian # NOTE: Imports overlays too
            nix-gaming.nixosModules.pipewireLowLatency
            nix-gaming.nixosModules.platformOptimizations
            nixosModules.decky
            nixosModules.desktop-plasma
            nixosModules._1password
          ];
        })

        (mkSystem "LT-masp" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            nixosModules.desktop-plasma
            nixosModules._1password
          ];
        })

        (mkSystem "sandbox" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            nixosModules.desktop-plasma
          ];
        })
      ];

    };
}
