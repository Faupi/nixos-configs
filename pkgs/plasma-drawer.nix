{ stdenv
, fetchFromGitHub
, kdePackages
, libsForQt5
, zip
}:
stdenv.mkDerivation rec {
  pname = "plasma-drawer";
  version = "unstable-20240423";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = pname;
    rev = "development";
    sha256 = "sha256-lBlrcX43PYJf+oTzgp9Zm35kRgWTsmdlHx9wV6kCulU=";
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
