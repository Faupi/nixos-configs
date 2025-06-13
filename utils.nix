# TODO: Create system and home-manager scoped variants/wrappers to eliminate the need to switch and repeat arguments

{ lib, ... }:
with lib;
rec {
  # Pointers to important locations
  configsPath = ./nixos/cfgs;
  homeConfigsPath = ./home-manager/cfgs;
  homeSharedConfigsPath = ./home-manager/cfgs/shared;

  # Recursively merges lists of attrsets
  # https://stackoverflow.com/a/54505212
  recursiveMerge = (with lib;
    attrList:
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
    f [ ] attrList);

  # Simple wrapper for mkIf to handle an else statement
  # https://discourse.nixos.org/t/mkif-vs-if-then/28521/4
  mkIfElse = p: yes: no: lib.mkMerge [
    (lib.mkIf p yes)
    (lib.mkIf (!p) no)
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

  # Runs a command under a derivation and returns its output
  # NOTE: This is sandboxed, so at most it's useable to get simple properties from derivations
  # TODO: Fucked, doesn't work on remote builders for some reason
  runCommand = pkgs: inputs: command:
    let
      script = pkgs.writeShellScript "runcommand-script" command;

      wrappingDerivation = pkgs.stdenv.mkDerivation {
        name = "runcommand";
        buildInputs = inputs;

        dontUnpack = true;
        dontConfigure = true;
        dontInstall = true;

        buildPhase = ''
          mkdir -p $out
          ${script} > $out/result
        '';
      };
      output = builtins.readFile "${wrappingDerivation}/result";
    in
    output;

  # Retrieves the font family of a supplied font package
  getFontFamily = pkgs: fontPackage: fontFileSubstring: (
    runCommand pkgs [ fontPackage pkgs.fontconfig ] ''
      find '${fontPackage}' -type f \( -iname "*${fontFileSubstring}*.ttf" -o -iname "*${fontFileSubstring}*.otf" \) -exec fc-query {} \; -quit \
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
    lib.mapAttrsRecursive
      (path: value:
        if lib.isAttrs value
        then mkOverrideRecursively level value
        else lib.mkOverride level value
      )
      attrset
  );
  # Helpers for build-in overrides
  # https://github.com/NixOS/nixpkgs/blob/045bc15dcb4e7d266a315e6cac126a57516b5555/lib/modules.nix#L1019-L1024
  mkDefaultRecursively = attrset: (mkOverrideRecursively 1000 attrset);
  mkForceRecursively = attrset: (mkOverrideRecursively 50 attrset);

  toRecursiveINI = attrs:
    with generators;
    let
      mkSectionName = name: name;

      flattenAttrs =
        let
          recurse = path: value:
            if isAttrs value && !isDerivation value then
              mapAttrsToList (name: value: recurse ([ name ] ++ path) value) value
            else if length path > 1 then {
              ${concatStringsSep "][" (reverseList (tail path))}.${head path} = value;
            } else {
              ${head path} = value;
            };
        in
        attrs: foldl recursiveUpdate { } (flatten (recurse [ ] attrs));

      toINI_ = generators.toINI { inherit mkSectionName; };
    in
    toINI_ (flattenAttrs attrs);

  # TODO: Detect system 32/64bit architecture, skip optimizations here if need be
  # https://github.com/Nix-QChem/NixOS-QChem/blob/461b04cc9b6fc2173fc37c6c29f1253ed443f92e/lib.nix
  # Create a stdenv with CPU optimizations
  mkOptimizedStdenv = pkgs: stdenv: arch: extraCFlags:
    (pkgs.withCFlags ("-march=${arch} -mtune=${arch} " + toString extraCFlags) stdenv).override {
      name = stdenv.name + "-${arch}";

      # Make sure respective CPU features are set
      hostPlatform = stdenv.hostPlatform //
        lib.mapAttrs (p: a: a arch) lib.systems.architectures.predicates;
    };

  # Optimizes a package for given architecture 
  mkOptimizedPackage = pkgs: package: arch: extraCFlags:
    (package.override { stdenv = mkOptimizedStdenv pkgs package.stdenv arch extraCFlags; }).overrideAttrs (old: {
      pname = old.pname + "-${arch}";
    });

  # Uses upstream nixpkgs utility to target local native CPU (locked to local build)
  # https://github.com/NixOS/nixpkgs/blob/c8baaf52bb105c42276f6286a7e8c317c890cbc4/pkgs/stdenv/adapters.nix#L283-L297
  mkLocalOptimizedPackage = pkgs: package: extraCFlags:
    (package.override (old: {
      stdenv = (pkgs.withCFlags extraCFlags (pkgs.impureUseNativeOptimizations package.stdenv)).override {
        name = old.stdenv.name + "-native";
      };
    })).overrideAttrs (old: {
      pname = old.pname + "-native";
    });

  # Reads a file and creates a new one with string replacements with the same syntax as `builtins.replaceStrings`
  replaceInFile = from: to: file: (
    builtins.toFile "replaceInFile" (
      builtins.replaceStrings from to (
        builtins.readFile file)
    )
  );
}
