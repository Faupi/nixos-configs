{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pluginName = "sticky-window-snapping";
  pname = "kde-${pluginName}";
  version = "1.0.1";

  src = fetchzip {
    url = "https://github.com/Flupp/sticky-window-snapping/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-RZ5J5wSoyj36e8yPBEy4G4KWpvR1up3u8xjQea0oCNc=";
    extension = "zip";
    stripRoot = true;

    # Only keep needed built package
    postFetch = ''
      tempDir="$TMPDIR/tempMove"
      mv "$out/package/*" "$tempDir"
      rm --recursive --dir "$out/"
      mv "$tempDir/*" "$out/"
    '';
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/kwin/scripts/${pluginName}"
    mkdir -p "$sharePath"
    cp -a * "$sharePath/"
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "A KWin script which lets snapped window edges stick together when one window is resized";
    homepage = "https://github.com/Flupp/sticky-window-snapping";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
