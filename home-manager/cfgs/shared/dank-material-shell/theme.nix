# Theme in nix for potential styling integration later maybe perhaps

{ ... }: {
  id = "faupi";
  author = "faupi";
  name = "Faupi's theme";
  description = "Faupi's custom theme branched from amoledBlack";
  version = "1.0.0";
  dark = {
    background = "#000000";
    backgroundText = "#FFFFFF";
    info = "#999999";
    outline = "#888888";
    primary = "#FF7B00";
    primaryContainer = "#CF6400";
    primaryText = "#000000";
    secondary = "#999999";
    surface = "#000000";
    surfaceContainer = "#000000";
    surfaceContainerHigh = "#111111";
    surfaceText = "#E6F0FF";
    surfaceTint = "#FF7B00";
    surfaceVariant = "#000000";
    surfaceVariantText = "#FFFFFF";

    error = "#DD0000";
    warning = "#FFCC00";
  };
}
