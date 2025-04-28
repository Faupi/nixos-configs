# Configurable Button
# https://github.com/pmarki/plasmoid-button

{ stdenv
, fetchFromGitHub
}: stdenv.mkDerivation {
  pname = "plasmoid-button";
  version = "unstable-2020-03-05";

  src = fetchFromGitHub {
    owner = "pmarki";
    repo = "plasmoid-button";
    rev = "a7106b2fd055ff551d66381df526254d0f3719b6";
    sha256 = "1dg34qyw05dvgpimjn6aar2pspllznby3b8gya7f7x267c43p0ij";
  };

  installPhase = ''
    path=$out/share/plasma/plasmoids/com.github.configurable_button
    mkdir -p $path
    cp -r * $path
  '';
}
