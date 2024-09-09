{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  vscodeExtPublisher = "LynithDev";
  vscodeExtName = "leaf-vscode";
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  name = "vscode-extension-${vscodeExtName}";
  version = "unstable-20221230";
  src = fetchFromGitHub {
    owner = vscodeExtPublisher;
    repo = vscodeExtName;
    rev = "ac2762a6e0d533fc600a7771112a73eb52b50958";
    sha256 = "sha256-LwRenq+6vnKZlM9nm0BT7AJFiVTB18X9FGdYaMvKBwU=";
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

  meta = {
    description = "VSCode color theme based on Leaf KDE Plasma Theme (https://github.com/qewer33/leaf-kde)";
    homepage = "https://github.com/LynithDev/leaf-vscode";
  };
}
