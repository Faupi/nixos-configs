{ stdenv
, unzip
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "vscode-extension-${vscodeExtName}";
  version = "unstable-2024-07-09";
  src = fetchFromGitHub {
    owner = "Faupi";
    repo = "highlight-regex";
    rev = "d283ec9b314dbc09451afd8c7896845caf041136";
    sha256 = "051z07xvmnh0xwi1xm1964anxxkypp4d4yw8jsmzac7px089g55f";
  };

  vscodeExtPublisher = "MickaelBlet";
  vscodeExtName = "highlight-regex";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  passthru = {
    inherit vscodeExtPublisher vscodeExtName vscodeExtUniqueId;
  };

  dontPatchELF = true;
  dontStrip = true;

  installPrefix = "share/vscode/extensions/${vscodeExtUniqueId}";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/$installPrefix"
    find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

    runHook postInstall
  '';
}
