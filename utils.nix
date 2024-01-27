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

  # Simple wrapper for mkIf to handle an else statement
  # https://discourse.nixos.org/t/mkif-vs-if-then/28521/4
  mkIfElse = p: yes: no: mkMerge [
    (mkIf p yes)
    (mkIf (!p) no)
  ];

  # Maps target directory contents' source to a source contents - used for symlinking individual files
  mapDirSources = sourceDir: targetDir:
    recursiveMerge (lib.attrsets.mapAttrsToList
      (name: type: { "${targetDir}/${name}".source = "${sourceDir}/${name}"; })
      (builtins.readDir sourceDir));

  # Wraps package binary with env variables and arguments
  wrapPkgBinary =
    { pkgs
    , package
    , binary ? null
    , nameAffix
    , variables ? { }
    , arguments ? [ ]
    }:
    (pkgs.symlinkJoin {
      name = "${package.name}-${nameAffix}";
      inherit (package) pname version meta;

      paths =
        let
          # Get full binary path and name for later replacing
          binaryPath = if binary != null then (lib.getExe' package binary) else (lib.getExe package);
          binaryName = lib.lists.last (lib.strings.splitString "/" binaryPath);

          # Parse variable setting and unsetting
          # TODO: MOVE UNSETTING TO THE FRONT, OTHERWISE IT POOPS ITSELF
          variableList = lib.attrsets.mapAttrsToList
            (
              name: value:
                if value != null
                then "${name}=${toString value}"
                else "-u ${name}"
            )
            variables;

          # These leave trailing spaces for proper formatting in the exec line
          variableString = lib.strings.concatStrings (lib.lists.forEach variableList (x: "${x} "));
          argumentString = lib.strings.concatStrings (lib.lists.forEach arguments (x: "${x} "));

          patched-package = pkgs.writeShellScriptBin binaryName ''
            exec env ${variableString}${binaryPath} ${argumentString}"$@"
          '';
        in
        [ patched-package package ];
    });

  # Forces the NIXOS_OZONE_WL to unset so the target binary doesn't try to run under Wayland
  disableWayland = { package, binary ? null, pkgs }:
    (
      wrapPkgBinary {
        inherit package binary pkgs;
        nameAffix = "x11";
        variables = {
          NIXOS_OZONE_WL = null; # Unset
        };
      }
    );

  # Forces the NIXOS_OZONE_WL on so the target binary tries to run under Wayland
  enableWayland = { package, binary ? null, pkgs }:
    (
      wrapPkgBinary {
        inherit package binary pkgs;
        nameAffix = "wayland";
        variables = {
          NIXOS_OZONE_WL = 1;
        };
      }
    );

  # Dumb wrapper for getting the file from makeDesktopItem directly
  makeDirectDesktopItem = pkgs: { name, ... }@args: "${pkgs.makeDesktopItem args}/share/application/${name}.desktop";

  makeAutostartItemLink = pkgs: { name, ... }@args: {
    source = makeDirectDesktopItem pkgs args;
    target = "xdg/autostart/${name}.desktop";
  };
}
