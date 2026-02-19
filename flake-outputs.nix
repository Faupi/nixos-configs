{ self
, nixpkgs-unstable
, jovian
, plasma-manager
, spicetify-nix
, flake-utils
, lsfg-vk
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
      config.allowUnfree = true; # TODO: switch to allowUnfreePredicate
      overlays =
        [ self.overlays.nur ]
        ++ extraOverlays
        ++ lib.lists.optional includeDefaultOverlay self.overlays.default
        ++ lib.lists.optional includeSharedOverlay self.overlays.shared;
    };
  overlays = (import ./overlays.nix { inherit inputs defaultNixpkgsConfig fop-utils; });

  fop-utils = (import ./utils.nix { inherit lib; });
  fop-flake-utils = (import ./flake-utils.nix { inherit self lib inputs fop-utils defaultNixpkgsConfig; });

  inherit (fop-flake-utils)
    mkHome mkHomeConfiguration
    homeManagerModules homeManagerConfigs

    mkSystem
    nixosModules;
  #!region
in
{
  inherit overlays;

  #region Users
  # Base home configs to be used with NixOS configs
  # TODO: Add custom check for homeUsers - issue(s) and PR open:
  #       - https://github.com/NixOS/nix/issues/6453
  #       - https://github.com/NixOS/nix/pull/8892
  #       - https://github.com/Mic92/dotfiles/blob/f44bac5dd6970ed3fbb4feb906917331ec3c2be5/flake.nix#L191
  # TODO: Make configs automatically require their needed modules (spicetify, plasma, etc.) - probably not possible, at least easily.
  homeUsers = fop-utils.recursiveMerge [
    (mkHome "faupi" {
      extraModules = [ ];
      graphicalModules = [
        plasma-manager.homeModules.plasma-manager
        homeManagerModules.kde-klipper
        homeManagerModules.zen-browser
        homeManagerModules.vivaldi-localstorage
        ({ ... }: spicetify-nix.homeManagerModules.default)

        homeManagerConfigs.shared.command-not-found
        homeManagerConfigs.shared.easyeffects
        homeManagerConfigs.shared.prusa-slicer
        homeManagerConfigs.shared.spicetify
      ];
    })

    (mkHome "masp" {
      extraModules = [ ];
      graphicalModules = [
        plasma-manager.homeModules.plasma-manager
        homeManagerModules.kde-klipper
        homeManagerModules.zen-browser
        homeManagerModules.vivaldi-localstorage
        ({ ... }: spicetify-nix.homeManagerModules.default)

        homeManagerConfigs.shared.command-not-found
        homeManagerConfigs.shared.syncDesktopItems
        homeManagerConfigs.shared.easyeffects
        homeManagerConfigs.shared.spicetify
      ];
    })
  ]; #!region

  #region Homes
  # Home configurations used by home-manager
  homeConfigurations = fop-utils.recursiveMerge [
    (mkHomeConfiguration "masp" {
      system = "x86_64-linux";
      variantArgs = { graphical = true; };
      targetNixpkgs = nixpkgs-unstable;
      extraModules = [
        {
          nixGLPackage = "intel";
          flake-configs.plasma.launcherIcon = "start-here-kubuntu";
          apparmor.enable = true;
        }
        homeManagerConfigs.shared.touchegg # X11, no native touchpad gestures
      ];
    })
  ]; #!region

  #region Systems
  # System configurations
  nixosConfigurations = fop-utils.recursiveMerge [
    (mkSystem "homeserver" {
      system = "x86_64-linux";
      # TODO: Split off most configurations similar to home-manager?
      extraModules = [
        nixosModules.notify-email
        nixosModules.service-containers
        nixosModules.vintagestory
      ];
    })

    (mkSystem "deck" {
      system = "x86_64-linux";
      extraModules = [
        jovian.nixosModules.jovian # NOTE: Imports overlays too
        nixosModules.steamdeck
        nixosModules.vintagestory
      ];
    })

    (mkSystem "go" {
      system = "x86_64-linux";
      extraModules = [
        jovian.nixosModules.jovian # NOTE: Imports overlays too
        lsfg-vk.nixosModules.default
        nixosModules.decky
        nixosModules.gaming
        nixosModules.handheld-daemon
      ];
    })

    (mkSystem "LT-masp" {
      system = "x86_64-linux";
      extraModules = [
        nixosModules.openvpn3-indicator
      ];
    })

    (mkSystem "sandbox" {
      system = "x86_64-linux";
      extraModules = [ ];
    })
  ]; #!region
} // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system: {
  # Other than overlay, we have packages independently declared in flake.
  /* NOTE: legacyPackages is used to get around the nesting problem 
           - https://discourse.nixos.org/t/flake-questions/8741
           - https://github.com/NixOS/nix/issues/9346
  */
  legacyPackages = (import ./pkgs {
    inherit lib;
    pkgs = import nixpkgs-unstable {
      inherit system;
    };
  });
})
