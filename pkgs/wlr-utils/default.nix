{ fetchFromGitHub
, ffmpeg
, leptonica
, lib
, libgbm
, libglvnd
, libxkbcommon
, pipewire
, pkg-config
, rustPlatform
, tesseract
, wayland
, makeWrapper
}:
rustPlatform.buildRustPackage rec {
  pname = "wlr-utils";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "sjourdois";
    repo = "wlr-utils";
    rev = "v${version}";
    hash = "sha256-ag+5EWrh1GwOhtOAW/cIz9KboX5fGW8ZWvdjpiJn7Sg=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libglvnd
    libxkbcommon
    wayland
    libgbm
    pipewire
    ffmpeg
    leptonica
    tesseract
  ];

  # libGL is DlOpen'd at runtime, needs to be linked
  postFixup = ''
    for prog in "$out"/bin/*; do
      wrapProgram "$prog" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}"
    done
  '';

  meta = with lib; {
    description = "Graphical window and screen picker for xdg-desktop-portal-wlr";
    homepage = "https://github.com/sjourdois/wlr-utils";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
