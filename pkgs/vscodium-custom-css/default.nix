{ cssPath ? null

, vscodium
, symlinkJoin
, runCommand
, lib
, nodejs
, jq
, moreutils
, bubblewrap
}:
assert lib.assertMsg (builtins.typeOf cssPath == "path") "vscodium-custom-css: cssPath must be a path literal";
assert lib.assertMsg (builtins.pathExists cssPath) "vscodium-custom-css: cssPath does not exist";
let
  # TODO: Rewrite to FHS handling
  vscodium-custom-css =
    runCommand "vscodium-custom-css-bit" { } ''
      orig="${vscodium}"
      res="lib/vscode/resources"
      appDir="$res/app/out/vs/code"

      wbRelPath=""
      for candidate in \
        "electron-sandbox/workbench" \
        "electron-browser/workbench"
      do
        if [ -e "$orig/$appDir/$candidate/workbench.html" ]; then
          wbRelPath="$appDir/$candidate/workbench.html"
          break
        fi
      done

      if [ -z "$wbRelPath" ]; then
        echo "Could not locate workbench.html" >&2
        exit 1
      fi

      echo "Add custom CSS"
      install -D "$orig/$wbRelPath" "$out/$wbRelPath"
      substituteInPlace "$out/$wbRelPath" \
        --replace-fail '<head>' '<head><style type="text/css">${builtins.replaceStrings [ "'" ] [ "'\\''" ] (builtins.readFile cssPath)}</style>'

      echo "Update checksum of HTML with custom CSS"
      checksum=$(${lib.getExe nodejs} ${./print-checksum.js} "$out/$wbRelPath")
      productPath="lib/vscode/resources/app/product.json"
      ${lib.getExe jq} ".checksums.\"$wbRelPath\" = \"$checksum\"" "$orig/$productPath" | ${lib.getExe' moreutils "sponge"} "$out/$productPath"

      # ==Overlay the binary==
      mkdir -p $out/bin

      cat > $out/bin/codium <<SH
      #!/usr/bin/env bash
      set -euo pipefail

      # Compose a minimal bwrap sandbox:
      # - Bind the whole root as-is
      # - Bind *overlayed* files on top of the base store paths
      exec ${lib.getExe bubblewrap} \
        --unshare-user-try \
        --bind / / \
        --dev-bind /dev /dev \
        --proc /proc \
        --ro-bind "$out/$wbRelPath" "$orig/$wbRelPath" \
        --ro-bind "$out/$productPath" "$orig/$productPath" \
        "$orig/bin/codium" --no-cached-data "\$@"
      SH
      chmod +x $out/bin/codium
    '';
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  paths = [ vscodium-custom-css vscodium ];
}
