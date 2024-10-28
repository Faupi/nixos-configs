{
  # TODO list:
  # - Actually resolve TODO lists (:
  # - Impermanence
  # - Switch default stable to default unstable for same lib across all systems - pkgs should have a stable overlay

  #region Inputs
  inputs = rec {
    # Base
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
      url = "github:nix-community/home-manager/release-24.05";
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

    nixgl.url = "github:guibou/nixGL";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
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

    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-utils.url = "github:numtide/flake-utils";

    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
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
    , home-manager
    , home-manager-unstable
    , jovian
    , plasma-manager
    , nixgl
    , spicetify-nix
    , chaotic
    , nix-gaming
    , flake-programs-sqlite
    , flake-utils
    , zen-browser
    , ...
    }@inputs:
    let
      lib = nixpkgs-unstable.lib;
    in
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
            ++ lib.lists.optional includeDefaultOverlay self.overlays.default
            ++ lib.lists.optional includeSharedOverlay self.overlays.shared;
        };

      fop-utils = (import ./utils.nix { inherit lib; });

      nixosModules = (import ./nixos/modules { inherit lib; });

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
              homeArgs' = { inherit config lib pkgs; } // homeArgs; # stupid but just to make sure nixd doesn't cry about unused arguments
              fullArgs = baseArgs // homeArgs' // specialArgs;

              sharedModules = [
                homeManagerModules.mutability
                homeManagerModules.nixgl
                homeManagerModules.apparmor
                chaotic.homeManagerModules.default
                homeSharedConfigs.base
              ]
              ++ lib.lists.optional graphical homeSharedConfigs.base-graphical;

              wrappedModules = builtins.map (mod: (mod fullArgs)) (
                sharedModules
                ++ extraModules
                ++ lib.lists.optionals graphical graphicalModules
              );

              userModule = import ./home-manager/cfgs/${name} fullArgs;
              graphicalModule = import ./home-manager/cfgs/${name}/graphical fullArgs;
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
              ./nixos/cfgs/base
              ./nixos/cfgs/${name}
              targetHomeManager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              chaotic.nixosModules.default
              flake-programs-sqlite.nixosModules.programs-sqlite
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
        nur = final: prev: {
          # Usage: pkgs.nur.repos.author.package
          nur = import nur {
            nurpkgs = prev;
            pkgs = prev;
          };
        };

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
              spicetify-extras = spicetify-nix.legacyPackages.${prev.system};
            }

            # Programs.sqlite
            {
              programs-sqlite = flake-programs-sqlite.packages.${prev.system}.programs-sqlite;
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
                zen-browser = {
                  inherit (zen-browser.packages.${prev.system})
                    generic specific;
                };
              };
            }

            # Custom overlays (sorry whoever has to witness this terribleness)
            # TODO: Move extra overlays to separate directory
            {
              vintagestory = (unstable.vintagestory.overrideAttrs
                (oldAttrs: rec {
                  version = "1.19.8";
                  src = builtins.fetchTarball {
                    url =
                      "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
                    sha256 =
                      "sha256:1lni0gbdzv6435n3wranbcmw9mysvnipz7f3v4lprjrsmgiirvd4";
                  };
                }));

              kdePackages = prev.kdePackages.overrideScope (finalKdePackages: prevKdePackages: {
                # Implement fix for divisible by 2 error from x264 https://invent.kde.org/plasma/kpipewire/-/merge_requests/176
                kpipewire = prevKdePackages.kpipewire.overrideAttrs (oldAttrs: {
                  patches = (oldAttrs.patches or [ ]) ++ [
                    ./pkgs/kpipewire-div2.patch
                  ];
                });
              });

              openvpn3 = prev.openvpn3.overrideAttrs (oldAttrs: {
                # Fix for missing include https://github.com/NixOS/nixpkgs/issues/349012
                patches = (oldAttrs.patches or [ ]) ++ [
                  ./pkgs/fix-openvpn-tests.patch
                ];
              });
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
            homeManagerModules.zen-browser
            spicetify-nix.homeManagerModules.default

            homeSharedConfigs.command-not-found
            homeSharedConfigs.kde-plasma
            homeSharedConfigs.kde-html-wallpaper
            homeSharedConfigs.maliit-keyboard
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects
            homeSharedConfigs.prusa-slicer
            homeSharedConfigs.spicetify
            homeSharedConfigs.vesktop
          ];
        })

        (mkHome "masp" {
          extraModules = [ ];
          graphicalModules = [
            plasma-manager.homeManagerModules.plasma-manager
            homeManagerModules.kde-klipper
            homeManagerModules.zen-browser
            spicetify-nix.homeManagerModules.default

            homeSharedConfigs.command-not-found
            homeSharedConfigs.syncDesktopItems
            homeSharedConfigs.kde-plasma
            homeSharedConfigs.vscodium
            homeSharedConfigs.easyeffects
            homeSharedConfigs.spicetify
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
              apparmor.enable = true;
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
            nixosModules.localsend
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
            nixosModules.desktop-plasma6
            nixosModules.gaming
            nixosModules._1password
            nixosModules.localsend
          ];
        })

        (mkSystem "LT-masp" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            nixosModules.desktop-plasma6
            nixosModules._1password
            nixosModules.localsend
          ];
        })

        (mkSystem "sandbox" {
          system = "x86_64-linux";
          targetNixpkgs = nixpkgs-unstable;
          targetHomeManager = home-manager-unstable;
          extraModules = [
            nixosModules.desktop-plasma6
          ];
        })
      ];

    } // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system:
    {
      # Other than overlay, we have packages independently declared in flake.
      packages = (import ./pkgs {
        inherit lib;
        pkgs = import nixpkgs-unstable {
          inherit system;
        };
      });
    }
    );
}
