{ stdenv
, unzip
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "vscode-extension-${vscodeExtName}";
  version = "1.2.1";
  src = fetchFromGitHub {
    owner = "MickaelBlet";
    repo = "highlight-regex";
    rev = "7f11cac9b1ed8677ca3860523e8000eb54d8844d";
    sha256 = "1rxikbkrz283kgl8n6nypvhs65h1djlb856y6qxg0b5679a8p370";
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
