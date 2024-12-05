# NOTE: Store does not work in-app, keeps playing loading animation without any logs
{ cargo-tauri_1
, cmake
, dbus
, fetchFromGitHub
, fetchNpmDeps
, freetype
, google-fonts
, gtk3
, libsoup
, nodejs
, npmHooks
, openssl
, pkg-config
, rustPlatform
, webkitgtk
}:
rustPlatform.buildRustPackage rec {
  pname = "css-loader-desktop";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "DeckThemes";
    repo = "CSSLoader-Desktop";
    rev = "v${version}";
    hash = "sha256-oh67c4fqTTCXZSrKurgsMZqne8iZz8GIo8iK+tuawLI=";
  };

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-/xdOeyMUQAWlNClX3+1I7P77Wbc+FaodVDxL0GBe+y4=";
  };

  patches = [
    ./fonts.patch
  ];

  cargoRoot = "src-tauri";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  buildAndTestSubdir = cargoRoot;

  buildInputs = [
    cmake
    dbus
    freetype
    gtk3
    libsoup
    openssl
    webkitgtk
  ];
  nativeBuildInputs = [
    cargo-tauri_1
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ];

  checkFlags = [
    "--skip=test_file_operation"
  ];

  postPatch = ''
    echo "Update cargo lock"
    (
      cp ${./Cargo.lock} src-tauri/Cargo.lock
    )

    echo "Remap google fonts"
    (
      fontDir="contexts"
      mkdir -p $fontDir
      googleFonts="${google-fonts.override { fonts = [ "Montserrat" "OpenSans" ]; }}"
      cp -T "$googleFonts/share/fonts/truetype/Montserrat[wght].ttf" "$fontDir/Montserrat.ttf"
      cp -T "$googleFonts/share/fonts/truetype/OpenSans[wdth,wght].ttf" "$fontDir/OpenSans.ttf"
    )
  '';

  buildPhase = ''
    runHook preBuild

    rustTarget=$(rustc -vV | sed -n 's|host: ||p')

    export HOME=$(mktemp -d)
    cargo tauri build \
      --bundles deb \
      --target $rustTarget

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r src-tauri/target/$rustTarget/release/bundle/deb/*/data/usr/* "$out"

    runHook postInstall
  '';
}
