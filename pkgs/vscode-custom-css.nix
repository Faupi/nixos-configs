{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  vscodeExtPublisher = "be5invis";
  vscodeExtName = "vscode-custom-css";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  name = "vscode-extension-${vscodeExtName}";
  version = "unstable-20240621";
  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "64c2d8b9126b2da6d2e9022ffdd5ae23d8e90407";
    sha256 = "sha256-O6fHy1raPa9JjDOgrLnXZ/6Er1T5JhwEyFjQzJhSQus=";
  };

  passthru = {
    inherit vscodeExtPublisher vscodeExtName vscodeExtUniqueId;
  };

  dontPatchELF = true;
  dontStrip = true;

  installPrefix = "share/vscode/extensions/${vscodeExtUniqueId}";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/$installPrefix"
    find . -mindepth 1 -maxdepth 1 | xargs -d'\n' mv -t "$out/$installPrefix/"

    runHook postInstall
  '';
}
