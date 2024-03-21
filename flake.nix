{
  # TODO list:
  # - Impermanence
  # - Autostarts
  #   - EasyEffects system-wide (Plasma + gamescope)
  #   - 1Password Plasma (desktop item with --silent in autostart)
  # - Switch default stable to default unstable for same lib across all systems - pkgs should have a stable overlay

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
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
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

    extest-flake = {
      url = "github:chaorace/extest-nix";
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
    , extest-flake
    , ...
    }@inputs:
      with flake-utils.lib;
      let
        lib = nixpkgs-unstable.lib;

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
          , targetNixpkgs ? nixpkgs
          , targetHomeManager ? home-manager
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
              homeManagerModules._1password
              spicetify-nix.homeManagerModule

              homeSharedConfigs.kde-plasma
              homeSharedConfigs.kde-klipper
              homeSharedConfigs.kde-konsole
              homeSharedConfigs.kde-html-wallpaper
              (homeSharedConfigs.kde-bismuth { })
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
              (homeSharedConfigs.kde-bismuth {
                useNixBismuth = false; # TODO: Needs to be built against Ubuntu's packages
              })
              homeSharedConfigs.kde-kwin-rules
              homeSharedConfigs.vscodium
              homeSharedConfigs.easyeffects
              homeSharedConfigs.firefox
              homeSharedConfigs.spicetify
              homeSharedConfigs.teams
            ];
          })
        ];

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
              nixosModules.desktop-plasma
              nixosModules.steamdeck
              nixosModules.vintagestory
            ];
            extraOverlays = [ extest-flake.overlays.default ];
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

      } // eachSystem [
        # TODO: Wrap with each used system?
        "x86_64-linux"
      ]
        (system: {
          # TODO: Set up formatter so `nix fmt` can use it - nixpkgs-fmt https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html
          # Expose extra packages from this flake
          packages = (import ./pkgs {
            inherit lib;
            pkgs = import nixpkgs (defaultNixpkgsConfig system { includeSharedOverlay = false; });
          });
        });
}
