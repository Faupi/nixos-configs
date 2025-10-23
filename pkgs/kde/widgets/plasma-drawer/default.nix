{ stdenv
, fetchFromGitHub
, kdePackages
, libsForQt5
, zip
}:
stdenv.mkDerivation {
  pname = "plasma-drawer";
  version = "unstable-dev-2025-02-23";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = "plasma-drawer";
    rev = "27878b8aa5e71762fa246e34c2034b905c733f1f";
    sha256 = "sha256-t+Y3zyW1hXMRkWjp2+W863tB9t61aGDJ9unC28mvNk4=";
  };

  # idk how I feel about this
  # NOTE: desktoptojson is only in qt5, hence why it's not in nativeBuildInputs
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
