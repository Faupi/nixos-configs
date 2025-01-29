# NOTE: Will log errors to do with symlinking and enabling remote CEF debugging if decky runs as another user, but this should be fine (29/01/2025)

{
  # Point to the Steam user's home directory
  steamUserHome ? null
, stdenv
, fetchzip
, lib
}:
stdenv.mkDerivation rec {
  pname = "SDH-CssLoader";
  version = "2.1.2";

  src = fetchzip {
    url = "https://github.com/DeckThemes/${pname}/releases/download/v${version}/SDH-CSSLoader-Decky.tar.gz";
    sha256 = "sha256-7FWCiGf9JqgpW/qzwc0qiYuZJfgJSbhvPdq1YVVaSyg=";
    stripRoot = true;
  };

  postPatch =
    (lib.strings.optionalString (steamUserHome != null) ''
      substituteInPlace css_utils.py \
        --replace-warn 'HOME = os.getenv("HOME")' 'HOME = "${steamUserHome}"'
    '');

  installPhase = ''
    mkdir -p $out
    cp -a ./* $out/
  '';
}
