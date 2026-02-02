{ deckyAssetsHost ? null
, stdenv
, fetchFromGitHub
, lib
}:
stdenv.mkDerivation {
  pname = "handheld-controller-glyphs";
  version = "unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "victor-borges";
    repo = "handheld-controller-glyphs";
    rev = "3892c41825f722198a82ba2b592729bae686d946";
    sha256 = "06g8djs3sblac1ywycfi96vp9gps4bj93ifkmbccd1d4psfmpl4y";
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
