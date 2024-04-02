# Patched NerdFont Hack to have clean braille glyphs for graph rendering, etc.
# Credits https://dee.underscore.world/blog/home-manager-fonts/

{ lib
, stdenvNoCC
, fetchurl
, nerdfonts
, nerd-font-patcher
, python3Packages
}:
let
  brailleFont = fetchurl {
    url = "https://yudit.org/download/fonts/UBraille/UBraille.ttf";
    sha256 = "sha256-S97BPzWSCinP5ymUYBjmwWlagHSpGIKmIkTkKPP/4SI=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "nerdfont-hack-braille";
  name = pname;

  nativeBuildInputs = with python3Packages; [
    python
    fontforge
    nerd-font-patcher
  ];

  # TODO: Maybe actually add a filter here?
  buildPhase = ''
    mkdir -p $out/share/fonts/truetype/BrailleNerdFonts
    for f in ${nerdfonts.override { fonts = [ "Hack" ]; }}/share/fonts/truetype/NerdFonts/*; do
      nerd-font-patcher $f --no-progressbars --careful --custom ${brailleFont} --outputdir $out/share/fonts/truetype/BrailleNerdFonts
    done
  '';

  dontUnpack = true;
  dontInstall = true;
  dontFixup = true;

  meta = with lib; {
    homepage = "https://github.com/ryanoasis/nerd-fonts";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
