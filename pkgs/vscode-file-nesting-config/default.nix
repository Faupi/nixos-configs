# https://github.com/antfu/vscode-file-nesting-config
# Fetches the clean JSON configuration from the repository

{ stdenvNoCC
, fetchFromGitHub
, nodejs
, ...
}:
stdenvNoCC.mkDerivation {
  name = "vscode-file-nesting-config.json";
  version = "unstable-2026-01-30";

  src = fetchFromGitHub {
    owner = "antfu";
    repo = "vscode-file-nesting-config";
    rev = "e05f5f33a6011e80d177ca1b26f6012aed35f0e0";
    sha256 = "13cr8qjbnj3x6gapxh3256mcyabfaafb5ymzsmfdzz86if29ivpd";
  };

  buildInputs = [ nodejs ];
  buildPhase = ''
    node -e 'require("${./get-config.js}").main()' > $out
  '';

  dontInstall = true;
  dontConfigure = true;
}
