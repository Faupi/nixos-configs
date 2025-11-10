{ fetchFromGitHub
, vscode-utils
, nodejs
, fetchNpmDeps
, npmHooks
, pkg-config
, python3
, libsecret
}:
vscode-utils.buildVscodeExtension rec {
  vscodeExtPublisher = "BeardedBear";
  vscodeExtName = "bearded-theme";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  pname = "${vscodeExtPublisher}.${vscodeExtName}";
  version = "unstable-20250421";

  src = fetchFromGitHub {
    owner = "BeardedBear";
    repo = "bearded-theme";
    rev = "65734e8f2e36fb825e3c6ecaf900777bc1322f73";
    hash = "sha256-AVYJxtBfAq2i7EXUUgExvw3ozZz0iLzjks9OS4rhmHg=";
  };
  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-4wN6K69GMXHA9ep9VMmzrV1hInbh7+UEH7hmFPPWCpg=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    pkg-config

    # for node-gyp
    python3
    libsecret
  ];

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  sourceRoot = "source";
}
