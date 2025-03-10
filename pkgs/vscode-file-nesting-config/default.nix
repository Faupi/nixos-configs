# https://github.com/antfu/vscode-file-nesting-config
# Fetches the clean JSON configuration from the repository

{ stdenvNoCC
, fetchFromGitHub
, nodejs
, ...
}:
stdenvNoCC.mkDerivation {
  name = "vscode-file-nesting-config.json";
  version = "unstable-2025-03-10";

  src = fetchFromGitHub {
    owner = "antfu";
    repo = "vscode-file-nesting-config";
    rev = "08707839ee25d7aff096407f750e390435307baf";
    sha256 = "1qsix186pnhvlyhgkn3cp71fjpmzv5kcpk4a4wwgv48ib8q36sxm";
  };

  buildInputs = [ nodejs ];
  buildPhase = ''
    node -e 'require("${./get-config.js}").main()' > $out
  '';

  dontInstall = true;
  dontConfigure = true;
}
