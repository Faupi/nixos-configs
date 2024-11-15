{ self
, nixpkgs-unstable
, home-manager-unstable
, jovian
, plasma-manager
, spicetify-nix
, nix-gaming
, flake-utils
, ...
}@inputs:
let
  lib = nixpkgs-unstable.lib;
in
let
  #region Helpers
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
  fop-flake-utils = (import ./flake-utils.nix { inherit self lib inputs fop-utils defaultNixpkgsConfig; });

  inherit (fop-flake-utils)
    mkHome mkHomeConfiguration
    homeManagerModules homeSharedConfigs
    mkSystem nixosModules;
in
{
  overlays = (import ./overlays.nix { inherit inputs defaultNixpkgsConfig fop-utils; });

  #region Users
  # Base home configs compatible with NixOS configs
  # TODO: Add custom check for homeUsers
  # TODO: Make configs automatically require their needed modules (spicetify, plasma, etc.) - probably not possible, at least easily.
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
  # Home configurations used by home-manager
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

}
  // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system: {
  # Other than overlay, we have packages independently declared in flake.
  packages = (import ./pkgs {
    inherit lib;
    pkgs = import nixpkgs-unstable {
      inherit system;
    };
  });
})
