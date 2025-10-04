{ cssPath ? null

, vscodium
, runCommand
, lib
, nodejs
, jq
, moreutils
, buildFHSEnvBubblewrap
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
    runCommand "vscodium-custom-css-bit" { } ''
      orig="${vscodium.out}"

      echo "Add custom CSS"
      install -D "$orig/${wbPath}" "$out/${wbPath}"
      substituteInPlace "$out/${wbPath}" \
        --replace-fail '<head>' '<head><style type="text/css">${cssContent}</style>'

      echo "Update checksum of HTML with custom CSS"
      checksum=$(${lib.getExe nodejs} ${./print-checksum.js} "$out/${wbPath}")
      ${lib.getExe jq} ".checksums.\"${wbPathInternal}\" = \"$checksum\"" "$orig/${productPath}" | ${lib.getExe' moreutils "sponge"} "$out/${productPath}"
    '';
in
buildFHSEnvBubblewrap {
  name = "codium";
  targetPkgs = p: [ ];
  runScript = "${lib.getExe vscodium}";

  extraBwrapArgs =
    [
      "--ro-bind ${overlay.out}/${wbPath} ${vscodium.out}/${wbPath}"
      "--ro-bind ${overlay.out}/${productPath} ${vscodium.out}/${productPath}"
    ];
}
