{ makeOpaque ? false # Best effort no-transparency patch. # TODO: tooltips
, stdenvNoCC
, fetchFromGitHub
, lib
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

  patches = lib.optional makeOpaque ./no-transparency.patch;
  postPatch = lib.strings.optionalString makeOpaque ''
    rm EclipseShade/desktoptheme/EclipseShade/dialogs/background.svgz
    
    cp -fT ${./background.svg} EclipseShade/desktoptheme/EclipseShade/opaque/dialogs/background.svg
    cp -fT ${./background.svg} EclipseShade/desktoptheme/EclipseShade/dialogs/background.svg
  '';

  dontBuild = true;

  installPhase = ''
    PLASMA_DIR="$out/share/plasma/desktoptheme"

    mkdir -p "$out" "$PLASMA_DIR"

    cp -r EclipseShade/desktoptheme/* "$PLASMA_DIR/"
  '';
}
