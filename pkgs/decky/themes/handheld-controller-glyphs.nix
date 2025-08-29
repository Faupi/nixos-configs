{ deckyAssetsHost ? null
, stdenv
, fetchFromGitHub
, lib
}:
stdenv.mkDerivation {
  pname = "handheld-controller-glyphs";
  version = "unstable-2025-08-07";

  src = fetchFromGitHub {
    owner = "victor-borges";
    repo = "handheld-controller-glyphs";
    rev = "de9ab7c5bcb1dbb37114faada55497816ee7820f";
    sha256 = "1mbz023i4bhv881hrdds6fcybbsnh7qvjcqsp0igdld53dfbr12g";
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
