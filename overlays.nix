{ inputs
, defaultNixpkgsConfig
, fop-utils
, ...
}:
let
  importChannel = flake: system: (import flake
    (defaultNixpkgsConfig system {
      includeDefaultOverlay = true;
      includeSharedOverlay = false;
    }));
in
{
  # Flake packages
  default = final: prev: (
    import ./pkgs {
      inherit (prev) lib;
      pkgs = prev;
    }
  );

  blender = inputs.blender.overlays.default;
  cachyos-kernel = inputs.nix-cachyos-kernel.overlays.pinned;
  # Shared between all systems
  shared = final: prev:
    let
      system = prev.stdenv.hostPlatform.system;

      stable = importChannel inputs.nixpkgs system;
      unstable = importChannel inputs.nixpkgs-unstable system;
      bleeding = importChannel inputs.nixpkgs-bleeding system;

      # Usage: pkgs.nur.repos.author.package
      nur = import inputs.nur {
        nurpkgs = prev;
        pkgs = prev;
      };
    in
    fop-utils.recursiveMerge [

      # Expose inputs
      {
        inherit stable unstable bleeding nur;
        spicetify-extras = inputs.spicetify-nix.legacyPackages.${system};
        programs-sqlite = inputs.flake-programs-sqlite.packages.${system}.programs-sqlite;
        zen-browser = inputs.zen-browser.packages.${system}.default;
        wivrn-connection-manager = inputs.wivrn-connection-manager.packages.${system}.default;
        millennium.steam = inputs.millennium.packages.${system}.millennium-steam;
      }

      # Misc/individual
      {
        vintagestory = (unstable.vintagestory.overrideAttrs
          (oldAttrs: rec {
            version = "1.19.8";
            src = fetchTarball {
              url =
                "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${version}.tar.gz";
              sha256 =
                "sha256:1lni0gbdzv6435n3wranbcmw9mysvnipz7f3v4lprjrsmgiirvd4";
            };
          }));
      }
    ];
}
