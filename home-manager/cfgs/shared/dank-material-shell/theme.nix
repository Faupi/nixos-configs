# Theme in nix for potential styling integration later maybe perhaps

{ ... }: {
  id = "faupi";
  author = "faupi";
  name = "Faupi's theme";
  description = "Faupi's custom theme originally branched from amoledBlack but customized heavily along the way";
  version = "1.0.0";
  dark = {
    primary = "#FB8C00";
    primaryText = "#000000";
    primaryContainer = "#CF6400";
    onPrimaryContainer = "#000000";
    softPrimaryContainer = "#FB8C00";
    inversePrimary = "#FFB74D";

    secondary = "#999999";
    secondaryContainer = "#171717";
    onSecondaryContainer = "#FFFFFF";

    tertiary = "#D6A15D";
    onTertiary = "#24190D";
    tertiaryContainer = "#49331D";
    onTertiaryContainer = "#F5DFC2";

    surface = "#000000";
    surfaceText = "#E6F0FF";
    surfaceVariant = "#050505";
    surfaceVariantText = "#FFFFFF";
    surfaceTint = "#FB8C00";

    background = "#000000";
    backgroundText = "#FFFFFF";

    surfaceContainerLowest = "#000000";
    surfaceContainerLow = "#020202";
    surfaceContainer = "#040404";
    surfaceContainerHigh = "#090909";
    surfaceContainerHighest = "#101010";

    surfaceBright = "#101010";
    surfaceDim = "#000000";

    outline = "#666666";
    outlineVariant = "#292929";

    containerTint = 0.5;
    selectedContainer = "#52300F";
    selectedContainerTint = 0.0;
    onSelectedContainer = "#FFFFFF";
    accentOnSelectedContainer = "#FB8C00";
    accentOnPrimaryContainer = "#000000";

    inverseSurface = "#D0D0D0";
    inverseOnSurface = "#000000";

    error = "#DD0000";
    errorText = "#FFFFFF";
    errorContainer = "#700000";
    errorContainerText = "#FFCCCC";

    warning = "#FFCC00";
    info = "#999999";
    success = "#4CAF50";
  };
}
