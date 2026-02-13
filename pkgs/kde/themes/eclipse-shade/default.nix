{ stdenvNoCC
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation {
  pname = "EclipseShade";
  version = "unstable-20250225";

  src = fetchFromGitHub {
    owner = "zayronxio";
    repo = "OpenArt";
    rev = "645bbdda92ca9eb453e681da4e22e5fac8792255";
    hash = "sha256-/yMRCRyT+yXA0HIJXxa6OP1zlfuL4+qDiSKDcR3Sb6Q=";
  };

  dontBuild = true;

  installPhase = ''
    PLASMA_DIR="$out/share/plasma/desktoptheme"

    mkdir -p "$out" "$PLASMA_DIR"

    cp -r EclipseShade/desktoptheme/* "$PLASMA_DIR/"
  '';
}
