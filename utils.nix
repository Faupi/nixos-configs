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

  # Forces the NIXOS_OZONE_WL to unset so the target binary doesn't try to run under Wayland
  disableWayland = { package, binary, pkgs }:
    (pkgs.symlinkJoin {
      name = "${package.name}-x11";
      inherit (package) pname version;

      paths =
        let
          patched-package = pkgs.writeShellScriptBin binary ''
            exec env -u NIXOS_OZONE_WL ${lib.getExe' package binary} "$@"
          '';
        in
        [ patched-package package ];
    });

  # Forces the NIXOS_OZONE_WL on so the target binary tries to run under Wayland
  enableWayland = { package, binary, pkgs }:
    (pkgs.symlinkJoin {
      name = "${package.name}-wayland";
      inherit (package) pname version;

      paths =
        let
          patched-package = pkgs.writeShellScriptBin binary ''
            exec NIXOS_OZONE_WL=1 ${lib.getExe' package binary} "$@"
          '';
        in
        [ patched-package package ];
    });
}
