{ stdenv
, fetchFromGitLab
}: stdenv.mkDerivation {
  pname = "carl";
  version = "unstable-20241019";

  theme = "Carl";
  colorScheme = "Carl";
  lookAndFeel = "Carl";

  src = fetchFromGitLab {
    owner = "jomada";
    repo = "carl";
    rev = "82a6ae859b9269ee5fb9f191d359b2f27098dd03";
    hash = "sha256-2ZuXBVHkRrfx73yuCPJ581lavvTSBjpRTPwIC0OKb+Q=";
  };

  dontBuild = true;

  # postPatch = ''
  #   patchShebangs .

  #   substituteInPlace install.sh \
  #     --replace-fail '/usr/share' "$out/share" \
  #     --replace-fail '$HOME/.local/share' "$out/share"
  # '';

  # NOTE: The upstream install script has a lot of issues
  installPhase = ''
    runHook preInstall

    THEME_NAME=Carl

    mkdir -p $out/share

    mkdir -p $out/share/plasma/desktoptheme
    mv $THEME_NAME $out/share/plasma/desktoptheme/

    mkdir -p $out/share/plasma/look-and-feel
    mv look-and-feel/* $out/share/plasma/look-and-feel/

    mkdir -p $out/share/aurorae/themes
    mv aurorae/* $out/share/aurorae/themes/

    mkdir -p $out/share/Kvantum
    mv Kvantum/* $out/share/Kvantum/

    mkdir -p $out/share/color-schemes
    mv color-schemes/* $out/share/color-schemes/

    mkdir -p $out/share/konsole
    mv konsole/* $out/share/konsole/

    mkdir -p $out/share/kate
    mv kate/* $out/share/kate/

    mkdir -p $out/share/wallpapers
    mv wallpaper/* $out/share/wallpapers/

    runHook postInstall
  '';

  meta = {
    description = "Dark Plasma theme with bluish gradients";
    homepage = "https://gitlab.com/jomada/carl";
  };
}
