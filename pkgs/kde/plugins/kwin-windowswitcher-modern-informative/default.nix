{ stdenvNoCC
, lib
, fetchFromGitLab
}:

stdenvNoCC.mkDerivation rec {
  pname = "kwin-windowswitcher-modern-informative";
  version = "unstable-2024-09-01";

  dontBuild = true;

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "ariasuni";
    repo = pname;
    rev = "97976a0882d21279bdb74462ed5da08c1f4b456c";
    hash = "sha256-QStYVfPk48qRweAVoVfzp+uiQ2S9zaq2S4oevyhuLG8=";
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/kwin/tabbox/modern_informative"
    mkdir -p "$sharePath"
    cp -a * "$sharePath/"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://framagit.org/ariasuni/kwin-windowswitcher-modern-informative";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
