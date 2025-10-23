{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pluginName = "de.unkn0wn.htmlwallpaper";
  pname = "kde-html-wallpaper";
  version = "2.5";

  src = fetchzip {
    url = "https://github.com/MarcelRichter-GitHub/HTMLWallpaper/releases/download/v${version}/de.unkn0wn.htmlwallpaper.zip";
    sha256 = "sha256-oefRHFWdZlxlVA0eLmoj0IT6LOqnKPHmsBXlsvVOqVo=";
    extension = "zip";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/wallpapers/"
    mkdir -p "$sharePath"
    cp -a * "$sharePath/"
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Allows you to display any HTML page as your KDE Plasma wallpaper";
    homepage = "https://github.com/MarcelRichter-GitHub/HTMLWallpaper";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
