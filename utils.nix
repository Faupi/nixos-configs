# TODO: Create system and home-manager scoped variants/wrappers to eliminate the need to switch and repeat arguments

{ lib, ... }:
with lib; rec {
  # Pointers to important locations
  configsPath = ./cfgs;
  homeConfigsPath = ./home-manager/cfgs;
  homeSharedConfigsPath = ./home-manager/cfgs/shared;

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
  # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/make-desktopitem/default.nix for arguments
  # Shitty workaround but for the checks it's worth it™
  makeDirectDesktopItem = pkgs: { name, ... }@args: "${pkgs.makeDesktopItem args}/share/applications/${name}.desktop";

  # Autostart symlink format wrapper for makeDesktopItem
  # TODO: Rework into system+home modules, this sucks to use otherwise
  makeAutostartItemLink = pkgs: { name, ... }@desktopArgs: { systemWide ? true, delay ? 0 }:
    let
      renderedArgs = recursiveMerge [
        desktopArgs
        {
          noDisplay = true;
        }
        (lib.attrsets.optionalAttrs (delay > 0) {
          # Add a 5 second delay because of task icon resolution loading problems on KDE
          exec = ''sh -c "sleep ${toString delay} && ${desktopArgs.exec}"'';
        })
      ];
    in
    {
      source = makeDirectDesktopItem pkgs renderedArgs;
      target = if systemWide then "xdg/autostart/${name}.desktop" else ".config/autostart/${name}.desktop";
    };

  # Runs a command under a derivation and returns its output
  # NOTE: This is sandboxed, so at most it's useable to get simple properties from derivations
  runCommand = pkgs: inputs: command:
    let
      wrappingDerivation = pkgs.stdenv.mkDerivation {
        name = "runcommand";
        buildInputs = inputs;

        dontUnpack = true;
        dontConfigure = true;
        dontInstall = true;

        buildPhase = ''
          mkdir -p $out
          result=$(${command})
          echo -n "$result" > $out/result
        '';
      };
      output = builtins.readFile (wrappingDerivation + "/result");
    in
    output;

  # Retrieves the font family of a supplied font package
  getFontFamily = pkgs: fontPackage: fontFileSubstring: (
    runCommand pkgs [ fontPackage pkgs.fontconfig ] ''
      find "${fontPackage}" -type f \( -iname "*${fontFileSubstring}*.ttf" -o -iname "*${fontFileSubstring}*.otf" \) -exec fc-query {} \; -quit \
      | grep '^\s\+family:' \
      | cut -d'"' -f2
    ''
  );

  # Remaps a list of attrsets to a nested attrset, keyed by the passed field
  # https://discourse.nixos.org/t/list-to-attribute-set/20929/4
  listToAttrsKeyed = field: list:
    builtins.listToAttrs (map
      (v: {
        name = v.${field};
        value = v;
      })
      list);

  # Applies mkOverride recursively to a whole attrset
  mkOverrideRecursively = level: attrset: (
    mapAttrsRecursive
      (path: value:
        if isAttrs value
        then mkOverrideRecursively level value
        else mkOverride level value
      )
      attrset
  );
  # Helpers for build-in overrides
  # https://github.com/NixOS/nixpkgs/blob/045bc15dcb4e7d266a315e6cac126a57516b5555/lib/modules.nix#L1019-L1024
  mkDefaultRecursively = attrset: (mkOverrideRecursively 1000 attrset);
  mkForceRecursively = attrset: (mkOverrideRecursively 50 attrset);
}
