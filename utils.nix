{ lib, ... }:
with lib; rec {
  # Recursively merges lists of attrsets
  # https://stackoverflow.com/a/54505212
  recursiveMerge = attrList:
    let
      f = attrPath:
        zipAttrsWith (n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values);
    in
    f [ ] attrList;

  # Maps target directory contents' source to a source contents - used for symlinking individual files
  mapDirSources = sourceDir: targetDir:
    recursiveMerge (lib.attrsets.mapAttrsToList
      (name: type: { "${targetDir}/${name}".source = "${sourceDir}/${name}"; })
      (builtins.readDir sourceDir));

  # Wrap the package's binaries with nixGL, while preserving the rest of
  # the outputs and derivation attributes.
  # Usage: `X.package = nixGLWrap pkgs.X args` - where `args` are the passed arguments from `home`
  # NOTE: home-only, requires the nixGL option module imported
  # https://github.com/nix-community/nixGL/issues/114#issuecomment-1585323281
  nixGLWrap = pkg: { config, pkgs, lib, ... }:
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
            echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
            echo "exec -a \"\$0\" ${lib.getExe config.nixGLPackage} $file \"\$@\"" >> "$out/bin/$(basename $file)"
            chmod +x "$out/bin/$(basename $file)"
          done
          shopt -u nullglob # Revert nullglob back to its normal default state
        '';
      }));
}
