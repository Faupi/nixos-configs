{ stdenv
, lib
, fetchFromGitHub
, libsForQt5
, kdePackages
}: stdenv.mkDerivation {
  pname = "plasmoid-button";
  version = "unstable-2020-03-05";

  src = fetchFromGitHub {
    owner = "pmarki";
    repo = "plasmoid-button";
    rev = "a7106b2fd055ff551d66381df526254d0f3719b6";
    sha256 = "1dg34qyw05dvgpimjn6aar2pspllznby3b8gya7f7x267c43p0ij";
  };

  dontWrapQtApps = true;
  nativeBuildInputs = [ libsForQt5.kcoreaddons kdePackages.kpackage ];

  installPhase = ''
    path=$out/share/plasma/plasmoids
    mkdir -p $path

    echo "Convert metadata to JSON format" 
    (
      desktoptojson -i metadata.desktop -o metadata.json
      rm metadata.desktop
    )

    kpackagetool6 --install . --packageroot $path
  '';

  meta = with lib; {
    description = "A Configurable Button Plasmoid (yet another on-off switch)";
    homepage = "https://github.com/pmarki/plasmoid-button";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
