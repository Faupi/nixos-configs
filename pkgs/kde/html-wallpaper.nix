{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pluginName = "de.unkn0wn.htmlwallpaper";
  pname = "kde-html-wallpaper";
  version = "2.2";

  src = fetchzip {
    url = "https://github.com/Marcel1202/HTMLWallpaper/releases/download/v${version}/de.unkn0wn.htmlwallpaper-${version}.zip";
    sha256 = "sha256-2ZiA6s+vWtC8o6giI0q+wsvOIBb4op0ugaw+LdoyJgI=";
    extension = "zip";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/wallpapers/${pluginName}"
    mkdir -p "$sharePath"
    cp -a * "$sharePath/"
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Allows you to display any HTML page as your KDE Plasma wallpaper";
    homepage = "https://github.com/Marcel1202/HTMLWallpaper";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
