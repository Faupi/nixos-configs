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

      # Groups
      {
        SOCIALS =
          let
            pkgs = importDefault inputs.group-socials;
          in
          {
            inherit (pkgs) vesktop discord telegram-desktop spotify;

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
          inherit (importDefault inputs.group-browsers)
            firefox ungoogled-chromium epiphany;
          inherit (inputs.chaotic.packages.${prev.system})
            firedragon; # TODO: Remove Chaotic once Firedragon is bundled in nixpkgs
          # TODO: If moving to Firedragon, figure out a way to reuse the home-manager firefox module for config
          zen-browser = {
            inherit (inputs.zen-browser.packages.${prev.system})
              generic specific;
          };
        };
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
