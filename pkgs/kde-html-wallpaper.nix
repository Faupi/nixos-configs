{ stdenv, lib, fetchzip, ... }:

stdenv.mkDerivation rec {
  pluginName = "de.unkn0wn.htmlwallpaper";
  pname = "kde-html-wallpaper";
  version = "2.2";

  src = fetchzip {
    url = "https://github.com/Marcel1202/HTMLWallpaper/releases/download/v${version}/de.unkn0wn.htmlwallpaper-${version}.zip";
    sha256 = "";
    extension = "zip";
    stripRoot = false;
  };

  # installPhase = ''
  #   sharePath="$out/share/plasma/wallpapers/${pluginName}"
  #   mkdir -p "$sharePath"
  #   mv "$out/*" "$sharePath/"
  # '';

  meta = with lib; {
    description = "Allows you to display any HTML page as your KDE Plasma wallpaper";
    homepage = "https://github.com/Marcel1202/HTMLWallpaper";
    license = licenses.gnu;
    platforms = platforms.linux;
  };
}
