{ fetchFromGitHub
, stdenvNoCC
}:
stdenvNoCC.mkDerivation {
  name = "Mystical-Blue-Theme";
  version = "20251007";

  theme = "JuxPlasma";
  colorScheme = "JuxTheme";
  lookAndFeel = "JuxPlasma";
  windowDecorations = {
    library = "org.kde.kwin.aurorae";
    theme = "__aurorae__svg__JuxDeco";
  };

  src = fetchFromGitHub {
    owner = "juxtopposed";
    repo = "Mystical-Blue-Theme";
    rev = "d28bf2a3528481ab41082c9febde8ff26f953c52";
    hash = "sha256-1+edTxJV/ATmttnc+2DrBPePkdFcyB2i3w5F6d/odxo=";
  };
  outputs = [ "out" "rofiConfig" "kvantumConfig" ];

  dontBuild = true;

  installPhase = ''
    COLOR_DIR="$out/share/color-schemes"
    AURORAE_DIR="$out/share/aurorae/themes"
    PLASMA_DIR="$out/share/plasma/desktoptheme"
    KVANTUM_DIR="$kvantumConfig"
    ROFI_DIR="$rofiConfig"

    mkdir -p "$out" "$COLOR_DIR" "$AURORAE_DIR" "$PLASMA_DIR" "$KVANTUM_DIR" "$ROFI_DIR"

    cp "$src/JuxTheme.colors" "$COLOR_DIR/"
    tar -xzf "$src/JuxDeco.tar.gz" -C "$AURORAE_DIR/"
    tar -xzf "$src/JuxPlasma.tar.gz" -C "$PLASMA_DIR/"

    tar -xzf "$src/NoMansSkyJux.tar.gz" -C "$KVANTUM_DIR/"
    cp "$src/rofi/config.rasi" "$ROFI_DIR/"
  '';
}
