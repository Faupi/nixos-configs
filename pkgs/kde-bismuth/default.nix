{ lib
, stdenv
, fetchFromGitHub
, libsForQt5
, cmake
, extra-cmake-modules
, esbuild
}:

stdenv.mkDerivation rec {
  pname = "bismuth";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "Bismuth-Forge";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-c13OFEw6E/I8j/mqeLnuc9Chi6pc3+AgwAMPpCzh974=";
  };

  patches = [
    ./0001-esbuild-config.patch
    ./0002-wayland-undefined.patch
    ./0003-monocle-borders.patch
    ./0004-ignore-dialog.patch
  ];

  cmakeFlags = [
    "-DUSE_TSC=OFF"
    "-DUSE_NPM=OFF"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    esbuild
  ];

  buildInputs = with libsForQt5; [
    kcoreaddons
    kwindowsystem
    plasma-framework
    systemsettings
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "A dynamic tiling extension for KWin";
    license = licenses.mit;
    maintainers = with maintainers; [ pasqui23 ];
    homepage = "https://bismuth-forge.github.io/bismuth/";
    inherit (libsForQt5.kwindowsystem.meta) platforms;
  };
}
