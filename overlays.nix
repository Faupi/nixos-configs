{ inputs
, defaultNixpkgsConfig
, fop-utils
, ...
}:
let
  importDefault = flake: system: (import flake
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

  # NUR - Nix user repositories
  nur = final: prev: {
    # Usage: pkgs.nur.repos.author.package
    nur = import inputs.nur {
      nurpkgs = prev;
      pkgs = prev;
    };
  };

  blender = inputs.blender.overlays.default;

  cachyos-kernel = inputs.nix-cachyos-kernel.overlays.pinned;

  # Shared between all systems
  shared = final: prev:
    let
      system = prev.stdenv.hostPlatform.system;

      stable = importDefault inputs.nixpkgs system;
      unstable = importDefault inputs.nixpkgs-unstable system;
      bleeding = importDefault inputs.nixpkgs-bleeding system;
    in
    fop-utils.recursiveMerge [

      # Expose inputs
      {
        inherit stable unstable bleeding;
        spicetify-extras = inputs.spicetify-nix.legacyPackages.${system};
        nixpkgs-xr = inputs.nixpkgs-xr.packages.${system};
        kwin-effects-forceblur = inputs.kwin-effects-forceblur.packages.${system};

        programs-sqlite = inputs.flake-programs-sqlite.packages.${system}.programs-sqlite;
        zen-browser = inputs.zen-browser.packages.${system}.default;
        suyu = inputs.suyu.packages.${system}.default;
        dgop = inputs.dgop.packages.${system}.default;
        wivrn-connection-manager = inputs.wivrn-connection-manager.packages.${system}.default;
      }

      # Misc/individual
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
      }
    ];
}
