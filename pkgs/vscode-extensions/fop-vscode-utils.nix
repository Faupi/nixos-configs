# Pretty much a carbon copy of vscode-utils with custom changes
# https://github.com/NixOS/nixpkgs/blob/5e3206daddccd100251ad3cad3a915dc02df9163/pkgs/applications/editors/vscode/extensions/vscode-utils.nix

{ unzip, stdenv, lib }:
let
  buildVscodeExtension =
    a@{
      # Only optional for backward compatibility.
      pname ? null
    , name ? "vscode-extension-${vscodeExtName}"
    , src
    , # Same as "Unique Identifier" on the extension's web page.
      # For the moment, only serve as unique extension dir.
      vscodeExtPublisher
    , vscodeExtName
    , vscodeExtUniqueId ? "${vscodeExtPublisher}.${vscodeExtName}"
    , configurePhase ? ''
        runHook preConfigure
        runHook postConfigure
      ''
    , buildPhase ? ''
        runHook preBuild
        runHook postBuild
      ''
    , dontPatchELF ? true
    , dontStrip ? true
    , nativeBuildInputs ? [ ]
    , patches ? [ ]
    , passthru ? { }
    , # Some .vsix files contain other directories (e.g., `package`) that we don't use.
      # If other directories are present but `sourceRoot` is unset, the unpacker phase fails.
      sourceRoot ? "extension"
    , ...
    }:
    stdenv.mkDerivation (
      (removeAttrs a [
        "vscodeExtUniqueId"
        "pname"
      ])
      // (lib.optionalAttrs (pname != null) {
        pname = "vscode-extension-${pname}";
      })
      // {
        passthru = passthru // {
          inherit vscodeExtPublisher vscodeExtName vscodeExtUniqueId;
        };

        inherit
          name
          configurePhase
          buildPhase
          dontPatchELF
          dontStrip
          sourceRoot
          patches
          ;

        installPrefix = "share/vscode/extensions/${vscodeExtUniqueId}";

        nativeBuildInputs = [ unzip ] ++ nativeBuildInputs;

        installPhase = ''

          runHook preInstall

          mkdir -p "$out/$installPrefix"
          find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

          runHook postInstall
        '';
      }
    );
in
{
  inherit buildVscodeExtension;
}
