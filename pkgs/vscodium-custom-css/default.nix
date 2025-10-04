# VSCodium with custom injected CSS
# NOTE: Uses bwrap, which is not ideal, but there doesn't seem to be a simple way to just directly overlay modded files without fully rebuilding each time.

{ cssPath ? null

, jq
, lib
, moreutils
, nodejs
, runCommand
, symlinkJoin
, vscodium
}:
let
  libraryName = "vscode";
  executableName = "codium";
  wrapperName = ".${executableName}-wrapped";

  resDir = "lib/${libraryName}/resources";
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
    '';
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  paths = [ overlay vscodium ];

  postBuild = ''
    orig="${vscodium.out}"
    # ==Overlay the binary==
    install -Dm755 "$orig/bin/${wrapperName}" "$out/bin/${wrapperName}"
    substituteInPlace "$out/bin/${wrapperName}" \
      --replace-fail "$orig/lib/${libraryName}" "$out/lib/${libraryName}"
    grep -q "VSCODE_PATH='$out/lib/${libraryName}'" "$out/bin/${wrapperName}" # check if sed succeeded

    install -Dm755 "$orig/bin/${executableName}" "$out/bin/${executableName}"
    substituteInPlace "$out/bin/${executableName}" \
      --replace-fail "$orig/bin/${wrapperName}" "$out/bin/${wrapperName}"

    install -Dm755 "$orig/lib/${libraryName}/bin/codium" "$out/lib/${libraryName}/bin/codium"
    substituteInPlace "$out/lib/${libraryName}/bin/codium" \
      --replace-fail "ELECTRON=" "VSCODE_PATH='$out/lib/${libraryName}'; ELECTRON="
    grep -q "VSCODE_PATH='$out/lib/${libraryName}'" "$out/lib/${libraryName}/bin/codium" # check if sed succeeded
  '';
}

