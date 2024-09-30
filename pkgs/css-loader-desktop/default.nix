{ buildNpmPackage
, cmake
, dbus
, fetchFromGitHub
, freetype
, google-fonts
, gtk3
, libsoup
, openssl
, pkg-config
, rustPlatform
, webkitgtk
, cargo-tauri
}:
let
  pname = "css-loader-desktop";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "DeckThemes";
    repo = "CSSLoader-Desktop";
    rev = "v${version}";
    hash = "sha256-oh67c4fqTTCXZSrKurgsMZqne8iZz8GIo8iK+tuawLI=";
  };

  frontend-build = buildNpmPackage {
    inherit version src;
    pname = "css-loader-desktop-ui";

    packageJSON = ./package.json;
    npmDepsHash = "sha256-/xdOeyMUQAWlNClX3+1I7P77Wbc+FaodVDxL0GBe+y4=";

    patches = [
      ./fonts.patch
    ];

    preBuild = ''
      fontDir="contexts"
      mkdir -p $fontDir
      googleFonts="${google-fonts.override { fonts = [ "Montserrat" "OpenSans" ]; }}"
      cp -T "$googleFonts/share/fonts/truetype/Montserrat[wght].ttf" "$fontDir/Montserrat.ttf"
      cp -T "$googleFonts/share/fonts/truetype/OpenSans[wdth,wght].ttf" "$fontDir/OpenSans.ttf"
    '';
    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      npm run build --offline && npm run export

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r out $out

      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  buildInputs = [ dbus openssl freetype libsoup gtk3 webkitgtk cmake ];
  nativeBuildInputs = [ cargo-tauri pkg-config ];

  sourceRoot = "${src.name}/src-tauri";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  checkFlags = [
    "--skip=test_file_operation"
  ];

  postPatch = ''
    echo "Update cargo lock"
    cp ${./Cargo.lock} Cargo.lock

    echo "Link frontend build"
    mkdir -p frontend-build
    cp -r ${frontend-build}/* frontend-build/

    echo "Map frontend resources and disable their automated build"
    substituteInPlace tauri.conf.json \
      --replace-fail '"distDir": "../out"' '"distDir": "frontend-build"' \
      --replace-fail '"beforeBuildCommand": "npm run build && npm run export",' ""
  '';

  buildPhase = ''
    runHook preBuild

    curTarget=$(rustc -vV | sed -n 's|host: ||p')
    cargo tauri build \
      --target $curTarget \
      --bundles deb

    runHook postBuild
  '';

  # TODO: Not sure how to substitute the amd64 affix but hey
  installPhase = ''
    runHook preInstall

    mv "target/$curTarget/release/bundle/deb/${pname}_${version}_amd64/data/usr" $out

    runHook postInstall
  '';
}
