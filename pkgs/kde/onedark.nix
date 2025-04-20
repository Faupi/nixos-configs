# One-Dark theme for KDE
# https://github.com/Prayag2/kde_onedark

{ stdenv
, fetchFromGitHub
}: stdenv.mkDerivation {
  pname = "kde-onedark";
  version = "unstable-20210809";

  src = fetchFromGitHub {
    owner = "Prayag2";
    repo = "kde_onedark";
    rev = "8a928843bb308ebe935f23b4e0f8c0a0259e0e32";
    hash = "sha256-3TYYX2mi/FiIajZbrA7C0HSEjaJFX13GzxxLFwPDKfE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    mkdir -p $out/share/aurorae/themes
    mv aurorae/themes/One-Dark/* $out/share/aurorae/themes/

    mkdir -p $out/share/color-schemes
    mv color-schemes/One-Dark/* $out/share/color-schemes/

    mkdir -p $out/share/wallpapers
    mv wallpaper/One-Dark/* $out/share/wallpapers/

    runHook postInstall
  '';
}
