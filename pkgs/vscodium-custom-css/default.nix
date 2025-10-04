# VSCodium with custom injected CSS
# NOTE: Uses bwrap, which is not ideal, but there doesn't seem to be a simple way to just directly overlay modded files without fully rebuilding each time.

{ cssPath ? null

, bubblewrap
, jq
, lib
, moreutils
, nodejs
, runCommand
, symlinkJoin
, vscodium
}:
let
  resDir = "lib/vscode/resources";
  appOutDir = "${resDir}/app/out";
  appVSRel = "vs/code";
  productPath = "${resDir}/app/product.json";

  wbPathsInternal = [
    "${appVSRel}/electron-sandbox/workbench/workbench.html"
    "${appVSRel}/electron-browser/workbench/workbench.html"
  ];
  wbPathInternal = lib.findFirst (p: builtins.pathExists "${vscodium.out}/${appOutDir}/${p}") (throw "Workbench.html could not be found") wbPathsInternal;
  wbPath = "${appOutDir}/${wbPathInternal}";

  overlay =
    let
      cssContent =
        if builtins.pathExists cssPath
        then builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.readFile cssPath)
        else throw "Invalid CSS path supplied";
    in
    runCommand "vscodium-custom-css-overlay" { } ''
      orig="${vscodium.out}"

      echo "Add custom CSS"
      install -D "$orig/${wbPath}" "$out/${wbPath}"
      substituteInPlace "$out/${wbPath}" \
        --replace-fail '<head>' '<head><style type="text/css">${cssContent}</style>'

      echo "Update checksum of HTML with custom CSS"
      checksum=$(${lib.getExe nodejs} ${./print-checksum.js} "$out/${wbPath}")
      ${lib.getExe jq} ".checksums.\"${wbPathInternal}\" = \"$checksum\"" "$orig/${productPath}" | ${lib.getExe' moreutils "sponge"} "$out/${productPath}"

      # ==Overlay the binary==
      mkdir -p $out/bin

      cat > $out/bin/codium <<SH
      #!/usr/bin/env bash
      set -euo pipefail

      exec ${lib.getExe bubblewrap} \
        --unshare-user-try \
        --bind / / \
        --dev-bind /dev /dev \
        --proc /proc \
        --ro-bind "$out/${wbPath}" "$orig/${wbPath}" \
        --ro-bind "$out/${productPath}" "$orig/${productPath}" \
        "$orig/bin/codium" "\$@"
      SH
      chmod +x $out/bin/codium
    '';
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  paths = [ overlay vscodium ];
}
