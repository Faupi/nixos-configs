{ inputs, fop-utils, homeManagerModules, pkgs, lib, ... }:
{
  home-manager = {
    useGlobalPkgs = false; # Use pkgs defined specifically for the user
    useUserPackages = false; # Keep packages mounted in the user home directory

    # Usually redundant thanks to mkHome, but direct home-manager definitions with module imports might fail otherwise. Keep in sync with baseArgs in mkHome in flake-utils.nix
    extraSpecialArgs = {
      inherit inputs fop-utils homeManagerModules;
    };

    # Throw replaced files in the trash. Actual backups end up flooding the filesystem over time.
    backupCommand = lib.getExe pkgs.trash-cli;

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
