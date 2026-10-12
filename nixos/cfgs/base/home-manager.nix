{ inputs, fop-utils, homeManagerModules, pkgs, ... }: {

  home-manager = {
    useGlobalPkgs = false; # Use pkgs defined specifically for the user
    useUserPackages = true; # Better flow for NixOS activation

    # Usually redundant thanks to mkHome, but direct home-manager definitions with module imports might fail otherwise. Keep in sync with baseArgs in mkHome in flake-utils.nix
    extraSpecialArgs = {
      inherit inputs fop-utils homeManagerModules;
    };

    # Move conflicting files to a unique name in-place to avoid collisions.
    backupCommand = pkgs.writeShellScript "home-manager-backup" /*sh*/''
      set -euo pipefail
      target="$1"

      # If the existing file is a symlink into the Nix store, just remove it instead of creating another backup.
      if [ -L "$target" ]; then
        resolved="$(readlink -f -- "$target")"
        if [[ "$resolved" == /nix/store/* ]]; then
          rm -- "$target"
          exit 0
        fi
      fi

      dir="$(dirname "$target")"
      base="$(basename "$target")"
      stamp="$(date +%Y%m%d%H%M%S)"
      backup="$(mktemp --tmpdir="$dir" "$base.backup-$stamp-XXXXXXXX")"
      mv -- "$target" "$backup"
    '';

    # Workaround for nixd to be able to evaluate custom per-user options, like flake-configs
    sharedModules = [
      ({ options, lib, ... }: {
        options._nixdOptions = lib.mkOption {
          default = options;
          internal = true;
          readOnly = true;
          type = lib.types.raw;
        };
      })
    ];
  };
}
