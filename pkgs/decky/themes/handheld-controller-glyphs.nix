{ deckyAssetsHost ? null
, stdenv
, fetchFromGitHub
, lib
}:
stdenv.mkDerivation rec {
  pname = "handheld-controller-glyphs";
  version = "unstable-20250129";

  src = fetchFromGitHub {
    owner = "victor-borges";
    repo = pname;
    rev = "312987d1519e9ba30610cd4e355131c4ba403906";
    sha256 = "sha256-YWLjkNLofFn76EwTqoxwxyU9rSl8uQcsoAXOS+o/WOM=";
  };

  postPatch = lib.strings.optionalString (deckyAssetsHost != null) ''
    for i in `grep -l -R 'themes_custom' .`; do
      echo "Patching assert URL in $i"
      substituteInPlace $i \
        --replace-fail "/themes_custom/" "${deckyAssetsHost}/themes/"
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -a ./* $out/
  '';
}
