# VSCodium with custom injected CSS
# NOTE: Uses proot, which unfortunately prevents privilege escalation

{ cssPath ? null

, proot
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

      ${lib.getExe proot} \
        -b "$out/${productPath}:$orig/${productPath}" \
        -b "$out/${wbPath}:$orig/${wbPath}" \
        "$orig/bin/codium" --no-sandbox "\$@"
      SH
      chmod +x $out/bin/codium
    '';
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  paths = [ overlay vscodium ];
}
