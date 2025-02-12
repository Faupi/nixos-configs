{ stdenv
, fetchFromGitHub
, kdePackages
, libsForQt5
, zip
}:
stdenv.mkDerivation rec {
  pname = "plasma-drawer";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-GQ3j78y/0XD1CENgglHsK/3b5783PbzNnNTAQ1rQm5w=";
  };

  # idk how I feel about this
  postPatch = ''
    # This may as well be an official change
    substituteInPlace Makefile \
      --replace-fail 'kreadconfig5' 'kreadconfig6' \
      --replace-fail 'kpackagetool6 -t Plasma/Applet' 'kpackagetool6'
    
    # Nix-specific subs
    substituteInPlace Makefile \
      --replace-fail 'desktoptojson' '${libsForQt5.kcoreaddons}/bin/desktoptojson' \
      --replace-fail 'kpackagetool6' 'kpackagetool6 --packageroot $(out)/share/plasma/plasmoids'
  '';

  nativeBuildInputs = [ kdePackages.kpackage kdePackages.kconfig zip ];
  dontWrapQtApps = true;
}
