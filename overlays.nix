{ inputs
, defaultNixpkgsConfig
, fop-utils
, ...
}:
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

  # Shared between all systems
  shared = final: prev:
    let
      importDefault = flake: (import flake
        (defaultNixpkgsConfig prev.system {
          includeDefaultOverlay = true;
          includeSharedOverlay = false;
        }));

      stable = importDefault inputs.nixpkgs;
      unstable = importDefault inputs.nixpkgs-unstable;
    in
    fop-utils.recursiveMerge [

      # Expose branches
      {
        inherit stable unstable; # TODO: This is awful for building, actually.
      }

      # Spicetify
      {
        spicetify-extras = inputs.spicetify-nix.legacyPackages.${prev.system};
      }

      # Programs.sqlite
      {
        programs-sqlite = inputs.flake-programs-sqlite.packages.${prev.system}.programs-sqlite;
      }

      # Zen browser
      {
        zen-browser = inputs.zen-browser.packages.${prev.system}.default;
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
