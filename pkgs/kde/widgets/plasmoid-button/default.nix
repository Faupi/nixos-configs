{ stdenv
, lib
, fetchFromGitHub
, kdePackages
}: stdenv.mkDerivation {
  pname = "plasmoid-button";
  version = "unstable-20240321";

  src = fetchFromGitHub {
    owner = "doncsugar";
    repo = "plasmoid-button";
    rev = "plasma6";
    sha256 = "sha256-eZgTzV7ttyWV4UxeLniboSL4dQpZDAPCkr2r+AfQfqo=";
  };

  dontWrapQtApps = true;
  nativeBuildInputs = [ kdePackages.kpackage ];

  installPhase = ''
    path=$out/share/plasma/plasmoids
    mkdir -p $path
    kpackagetool6 --install . --packageroot $path
  '';

  meta = with lib; {
    description = "A Configurable Button Plasmoid (yet another on-off switch)";
    homepage = "https://github.com/doncsugar/plasmoid-button";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
