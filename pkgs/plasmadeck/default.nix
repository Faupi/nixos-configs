{ stdenv
, fetchFromGitHub
}: stdenv.mkDerivation {
  pname = "plasmadeck-kde-theme";
  version = "20220902";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo = "plasma-deck";
    rev = "b03f24240b4d7450524e1731aa19b8884df9c864";
    sha256 = "sha256-GZanIQdGiLp2Luosr+LwED1xirgMVCHbU3bTRsNMLiU=";
  };

  patches = [
    ./colors.patch
  ];

  # NOTE: We don't install any wallpapers
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    mv color-schemes $out/share/color-schemes
    mv plasma $out/share/plasma
    mv aurorae $out/share/aurorae

    runHook postInstall
  '';
}
