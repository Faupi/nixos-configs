{ fetchFromBitbucket, stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "yet-another-monochrome-icon-set";
  version = "unstable-20251003";

  src = fetchFromBitbucket {
    owner = "dirn-typo";
    repo = "yet-another-monochrome-icon-set";
    rev = "014d2f235546c7a2fd9bb859ab5469babd19c248";
    sha256 = "sha256-/P69zeMVgJyW2tUpE1ZPE7jzEY/jvn4Mrm2cSAkn+GE=";
  };
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    iconDir="$out/share/icons/yet-another-monochrome-icon-set"
    mkdir -p "$iconDir"

    shopt -s extglob
    cp -r !('LICENSE'|'readme.md'|'Authors'|'changelog') "$iconDir/"

    runHook postInstall
  '';
}

