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
  # Base home configs to be used with NixOS configs
  # TODO: Add custom check for homeUsers - issue(s) and PR open:
  #       - https://github.com/NixOS/nix/issues/6453
  #       - https://github.com/NixOS/nix/pull/8892
  # TODO: Make configs automatically require their needed modules (spicetify, plasma, etc.) - probably not possible, at least easily.
  homeUsers = fop-utils.recursiveMerge [
    (mkHome "faupi" {
      extraModules = [ ];
      graphicalModules = [
        plasma-manager.homeManagerModules.plasma-manager
        homeManagerModules.kde-klipper
        homeManagerModules.zen-browser
        spicetify-nix.homeManagerModules.default

        homeSharedConfigs.shared.command-not-found
        homeSharedConfigs.shared.kde-plasma
        homeSharedConfigs.shared.kde-html-wallpaper
        homeSharedConfigs.shared.maliit-keyboard
        homeSharedConfigs.shared.vscodium
        homeSharedConfigs.shared.easyeffects
        homeSharedConfigs.shared.prusa-slicer
        homeSharedConfigs.shared.spicetify
        homeSharedConfigs.shared.vesktop
      ];
    })

    (mkHome "masp" {
      extraModules = [ ];
      graphicalModules = [
        plasma-manager.homeManagerModules.plasma-manager
        homeManagerModules.kde-klipper
        homeManagerModules.zen-browser
        spicetify-nix.homeManagerModules.default

        homeSharedConfigs.shared.command-not-found
        homeSharedConfigs.shared.syncDesktopItems
        homeSharedConfigs.shared.kde-plasma
        homeSharedConfigs.shared.vscodium
        homeSharedConfigs.shared.easyeffects
        homeSharedConfigs.shared.spicetify
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
        homeSharedConfigs.shared.touchegg # X11, no native touchpad gestures
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
        nixosModules.openvpn3-indicator
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
} // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system: {
  # Other than overlay, we have packages independently declared in flake.
  packages = (import ./pkgs {
    inherit lib;
    pkgs = import nixpkgs-unstable {
      inherit system;
    };
  });
})
