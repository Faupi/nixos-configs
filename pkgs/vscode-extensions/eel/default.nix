{ fetchFromGitHub
, vscode-utils
, lib
, buildNpmPackage

, nodejs
}:
vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "eclairevoyant";
  vscodeExtName = "eel";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  pname = "${vscodeExtPublisher}.${vscodeExtName}";
  version = "unstable-20251114b";

  src = fetchFromGitHub {
    owner = "Faupi";
    repo = "eel";
    rev = "7d67183632f99bab981a64ab42c2aeb9d106b7aa";
    hash = "sha256-szm8mKTw2RF1zOW5uAn1ccycveJDDWToGRu31ESfBl8=";
  };
  utilitiesDeps = buildNpmPackage {
    pname = "utilities";
    inherit version;
    src = "${src}/utilities";
    npmDepsHash = "sha256-E89XJEQl4YDknL99cGWrNxFjFnbKPVPnovOJy8LWkdk=";

    dontNpmBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/
    '';
  };

  nativeBuildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    ln -s ${utilitiesDeps}/node_modules ./node_modules
    make syntax

    runHook postBuild
  '';

  sourceRoot = "source";
}
