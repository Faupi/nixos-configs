{ config, lib, pkgs, ... }:
with lib;
{
  options = {
    nixGLPackage =
      let
        mapping = with pkgs.nixgl; {
          auto = auto.nixGLDefault;
          intel = nixGLIntel;
          mesa = nixGLMesa;
          nvidia = nixGLNvidia;
          nvidia-bumblebee = nixGLNvidiaBumblebee;
        };
      in
      lib.mkOption {
        type = with lib.types;
          nullOr (
            either
              (package)
              (enum (lib.attrsets.mapAttrsToList (name: value: name) mapping)) # Take keys from mapping
          );
        default = null;
        visible = false;
        description = ''
          Will be used in commands which require working OpenGL.

          Needed on non-NixOS systems.
        '';
        apply = input:
          (
            if (isString input)
            then (mapping.${input})
            else input # Package or null
          );
      };
  };

  config = {
    # Add appropriate nixGL package to user's environment
    home.packages = (mkIf (config.nixGLPackage != null) [ config.nixGLPackage ]);

    # TODO: Add wrapPackages function to do it for more at a time? Easier usage: `home.packages = with pkgs; (config.lib.nixgl.wrapPackages [ filelight krita ]);`

    lib.nixgl = {
      # Wrap the package's binaries with nixGL, while preserving the rest of the outputs and derivation attributes.
      # Usage: `X.package = config.lib.nixgl.wrapPackage pkgs.X`
      # https://github.com/nix-community/nixGL/issues/114#issuecomment-1585323281
      wrapPackage = pkg:
        if config.nixGLPackage == null then
          pkg
        else
          (pkg.overrideAttrs (old: {
            name = "nixGL-${pkg.name}";
            buildCommand = ''
              set -eo pipefail

              ${
                pkgs.lib.concatStringsSep "\n" (map (outputName: ''
                  echo "Copying output ${outputName}"
                  set -x
                  cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
                  set +x
                '') 
                (old.outputs or [ "out" ]))
              }

              rm -rf $out/bin/*
              shopt -s nullglob # Prevent loop from running if no files
              for file in ${pkg.out}/bin/*; do
                echo "#!${lib.getExe pkgs.bash}" > "$out/bin/$(basename $file)"
                echo "exec -a \"\$0\" ${lib.getExe config.nixGLPackage} $file \"\$@\"" >> "$out/bin/$(basename $file)"
                chmod +x "$out/bin/$(basename $file)"
              done
              shopt -u nullglob # Revert nullglob back to its normal default state
            '';
          }));
    };
  };
}
