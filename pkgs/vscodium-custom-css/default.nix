# VSCodium with custom injected CSS
# NOTE: Uses bwrap, which unfortunately prevents privilege escalation

{ cssPath ? null
, bubblewrap
, jq
, lib
, moreutils
, nodejs
, runCommand
, writeShellApplication
, symlinkJoin
, vscodium
, systemd
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

  patched = runCommand "vscodium-custom-css-patched"
    {
      buildInputs = [ jq moreutils nodejs ];
      inherit wbRel wbRelFull productRel cssContent;
      orig = vscodium.out;
      checksumGetter = ./print-checksum.js;
    } /*sh*/''
    set -euo pipefail

    # copy and patch workbench.html
    install -D "$orig/$wbRelFull" "$out/$wbRelFull"
    substituteInPlace "$out/$wbRelFull" \
      --replace-fail '<head>' "<head><style type=\"text/css\">$cssContent</style>"

    # update product.json checksum
    install -D "$orig/$productRel" "$out/$productRel"
    checksum=$(node $checksumGetter "$out/$wbRelFull")
    jq ".checksums.\"$wbRel\" = \"$checksum\"" "$out/$productRel" | sponge "$out/$productRel"
  '';

  wrapper = writeShellApplication {
    name = "codium";
    runtimeInputs = [ bubblewrap ];
    runtimeEnv = { inherit patched systemd vscodium wbRelFull productRel; };
    text = /*sh*/''
      set -euo pipefail

      exec bwrap \
        --bind / / \
        --proc /proc \
        --dev-bind /dev /dev \
        --tmpfs $systemd/lib/systemd/ssh_config.d \
        --bind $patched/$wbRelFull $vscodium/$wbRelFull \
        --bind $patched/$productRel $vscodium/$productRel \
        $vscodium/bin/codium --no-sandbox "$@"
    '';
  };
in
symlinkJoin {
  name = "vscodium-custom-css";
  inherit (vscodium) pname version meta;
  paths = [ wrapper patched vscodium ];
}
