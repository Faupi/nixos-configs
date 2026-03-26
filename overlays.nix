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

  # Shared between all systems
  shared = final: prev:
    let
      stable = importDefault inputs.nixpkgs prev.system;
      unstable = importDefault inputs.nixpkgs-unstable prev.system;
      bleeding = importDefault inputs.nixpkgs-bleeding prev.system;
    in
    fop-utils.recursiveMerge [

      # Expose inputs
      {
        inherit stable unstable bleeding;
        spicetify-extras = inputs.spicetify-nix.legacyPackages.${prev.system};
        nixpkgs-xr = inputs.nixpkgs-xr.packages.${prev.system};
        kwin-effects-forceblur = inputs.kwin-effects-forceblur.packages.${prev.system};

        programs-sqlite = inputs.flake-programs-sqlite.packages.${prev.system}.programs-sqlite;
        zen-browser = inputs.zen-browser.packages.${prev.system}.default;
        suyu = inputs.suyu.packages.${prev.system}.default;
        dgop = inputs.dgop.packages.${prev.system}.default;
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

        mesa-25_3_5 = inputs.nixpkgs-mesa-25_3_5.legacyPackages.${prev.system}.mesa;
        mesa32-25_3_5 = inputs.nixpkgs-mesa-25_3_5.legacyPackages.${prev.system}.pkgsi686Linux.mesa;
      }
    ];
}
