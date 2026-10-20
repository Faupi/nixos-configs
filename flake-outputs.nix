{ self
, nixpkgs-unstable
, jovian
, plasma-manager
, spicetify-nix
, flake-utils
, playit
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
        [ ]
        ++ extraOverlays
        ++ lib.lists.optional includeDefaultOverlay self.overlays.default
        ++ lib.lists.optional includeSharedOverlay self.overlays.shared;
    };
  overlays = (import ./overlays.nix { inherit inputs defaultNixpkgsConfig fop-utils; });

  fop-utils = (import ./utils.nix { inherit lib; });
  fop-flake-utils = (import ./flake-utils.nix { inherit self lib inputs fop-utils defaultNixpkgsConfig; });

  inherit (fop-flake-utils)
    mkHome mkHomeConfiguration
    homeManagerConfigs

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
  homeUsers = fop-utils.recursiveMerge [
    (mkHome "faupi" {
      sharedConfigs = import ./home-manager/cfgs/faupi/shared-configs.nix;
      extraOverlays = [
        self.overlays.nur
        self.overlays.blender
      ];
      extraModules = [
        # TODO: Convert rest of config modules
        homeManagerConfigs.shared.command-not-found
        homeManagerConfigs.shared.easyeffects
        homeManagerConfigs.shared.prusa-slicer
        homeManagerConfigs.shared.spicetify
      ];
    })

    (mkHome "masp" {
      sharedConfigs = import ./home-manager/cfgs/masp/shared-configs.nix;
      extraOverlays = [ self.overlays.nur ];
      extraModules = [
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
      targetNixpkgs = nixpkgs-unstable;
      extraOverlays = [ self.overlays.nur ];
      extraModules = [
        {
          nixGLPackage = "intel";
          apparmor.enable = true;
        }
      ];
    })
  ]; #!region

  #region Systems
  # System configurations
  nixosConfigurations = fop-utils.recursiveMerge [
    (mkSystem "beaver" {
      system = "x86_64-linux";
      sharedConfigs = import ./nixos/cfgs/beaver/shared-configs.nix;
      extraModules = [
        nixosModules.notify-email
        nixosModules.service-containers
        nixosModules.vintagestory
      ];
    })

    (mkSystem "fox" {
      system = "x86_64-linux";
      sharedConfigs = import ./nixos/cfgs/fox/shared-configs.nix;
      extraModules = [
        jovian.nixosModules.jovian # NOTE: Imports overlays too
        nixosModules.decky
        nixosModules.handheld-daemon
        nixosModules.ntsync
      ];
    })

    (mkSystem "lynx" {
      system = "x86_64-linux";
      extraOverlays = [ self.overlays.cachyos-kernel ];
      sharedConfigs = import ./nixos/cfgs/lynx/shared-configs.nix;
      extraModules = [
        nixosModules.ntsync
        playit.nixosModules.default
      ];
    })

    (mkSystem "raven" {
      system = "x86_64-linux";
      sharedConfigs = import ./nixos/cfgs/raven/shared-configs.nix;
      extraModules = [
        nixosModules.openvpn3-indicator
      ];
    })

    (mkSystem "sandbox" {
      system = "x86_64-linux";
      sharedConfigs = import ./nixos/cfgs/sandbox/shared-configs.nix;
      extraModules = [ ];
    })
  ]; #!region
} // flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ] (system: {
  # Used by `nix fmt`
  formatter = (import nixpkgs-unstable { inherit system; }).nixpkgs-fmt;

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
