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
  nativeBuildInputs = [ pkg-config ];

  sourceRoot = "${src.name}/src-tauri";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  checkFlags = [
    "--skip=test_file_operation"
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock

    mkdir -p frontend-build
    cp -r ${frontend-build}/* frontend-build/

    substituteInPlace tauri.conf.json \
      --replace '"distDir": "../out"' '"distDir": "frontend-build"'
  '';

  postInstall = ''
    mv $out/bin/app $out/bin/css-loader-desktop
  '';
}
