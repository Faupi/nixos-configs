{ stdenv
, fetchFromGitHub
}: stdenv.mkDerivation {
  pname = "kde-active-accent-decorations";
  version = "unstable-2023-02-19";

  src = fetchFromGitHub {
    owner = "nclarius";
    repo = "Plasma-window-decorations";
    rev = "02058699173f5651816d4cb31960d08b45553255";
    sha256 = "1lm0caz6ais3k20w8zibv6527kvss0brxgk4hm8m5npa7yv570iv";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/aurorae/themes
    mv ActiveAccent* $out/share/aurorae/themes/

    runHook postInstall
  '';
}
