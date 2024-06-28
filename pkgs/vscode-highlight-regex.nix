{ stdenv
, unzip
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  name = "vscode-extension-${vscodeExtName}";
  version = "1.2.0";
  src = fetchFromGitHub {
    owner = "MickaelBlet";
    repo = "highlight-regex";
    rev = "60cec8c8a81bb6d54aabd6cfb4d6589f8789885e";
    sha256 = "0sp3q8z33iw17lnnjkm5m1f9fcjgyy6mywaijizlwfmw73652g6c";
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
