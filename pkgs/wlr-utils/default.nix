{ fetchFromGitHub
, ffmpeg
, leptonica
, lib
, libgbm
, libGL
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
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "sjourdois";
    repo = "wlr-utils";
    rev = "v${version}";
    hash = "sha256-2bodQDWTGqv9OIOq/aZijUv2L2+ii+KjodQn9sUIzks=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libGL
    libxkbcommon
    wayland
    libgbm
    pipewire
    ffmpeg
    leptonica
    tesseract
  ];

  postFixup = ''
    wrapProgram $out/bin/wlr-chooser \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL ]}
  '';

  meta = with lib; {
    description = "Graphical window and screen picker for xdg-desktop-portal-wlr";
    homepage = "https://github.com/sjourdois/wlr-utils";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
