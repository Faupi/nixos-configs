# VSCodium with custom injected CSS
# NOTE: Uses bwrap, which unfortunately prevents privilege escalation

{ cssPath ? null
, bubblewrap
, jq
, lib
, moreutils
, nodejs
, runCommand
, writeShellScriptBin
, symlinkJoin
, vscodium
}:

let
  resDir = "lib/vscode/resources";
  appOutDir = "${resDir}/app/out";
  appVSRel = "vs/code";
  productRel = "${resDir}/app/product.json";

  wbCandidates = [
    "${appVSRel}/electron-sandbox/workbench/workbench.html"
    "${appVSRel}/electron-browser/workbench/workbench.html"
  ];
  wbRel = lib.findFirst
    (p: builtins.pathExists "${vscodium.out}/${appOutDir}/${p}")
    (throw "Workbench.html could not be found")
    wbCandidates;
  wbRelFull = "${appOutDir}/${wbRel}";

  cssContent =
    if builtins.pathExists cssPath
    then builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.readFile cssPath)
    else throw "Invalid CSS path supplied";

  patched = runCommand "vscodium-custom-css-patched" { } ''
    set -euo pipefail
    orig="${vscodium.out}"

    # copy and patch workbench.html
    install -D "$orig/${wbRelFull}" "$out/${wbRelFull}"
    substituteInPlace "$out/${wbRelFull}" \
      --replace-fail '<head>' '<head><style type="text/css">${cssContent}</style>'

    # update product.json checksum
    install -D "$orig/${productRel}" "$out/${productRel}"
    checksum=$(${lib.getExe nodejs} ${./print-checksum.js} "$out/${wbRelFull}")
    ${lib.getExe jq} ".checksums.\"${wbRel}\" = \"$checksum\"" \
      "$out/${productRel}" | ${lib.getExe' moreutils "sponge"} "$out/${productRel}"
  '';

  wrapper = writeShellScriptBin "codium" ''
    set -euo pipefail

    exec ${lib.getExe bubblewrap} \
      --bind / / \
      --proc /proc \
      --dev-bind /dev /dev \
      --bind ${patched}/${wbRelFull} ${vscodium.out}/${wbRelFull} \
      --bind ${patched}/${productRel} ${vscodium.out}/${productRel} \
      ${vscodium.out}/bin/codium --no-sandbox "$@"
  '';
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  # include vscodium, the wrapper, and (optionally) the patched output
  paths = [ wrapper patched vscodium ];
}
