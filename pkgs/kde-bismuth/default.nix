# TODO: For Ubuntu, needs to be built manually:
# (Note that I'm not good with Linux at the time of writing. Hi Jack)
/*
  sudo apt-get install esbuild cmake make -y
  nix develop .#kde-bismuth --unpack
  cd source
  cmake -DUSE_TSC=OFF -DUSE_NPM=OFF
  sudo make install
*/

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
    ./nix-esbuild-config.patch

    # Prefixing numbers are official PRs at https://github.com/Bismuth-Forge/bismuth/pulls
    ./396-monocle-borders.patch
    ./480-ignore-dialog.patch
    ./490-wayland-undefined.patch
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
