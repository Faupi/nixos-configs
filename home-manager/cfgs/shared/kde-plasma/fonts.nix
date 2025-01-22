{ ... }:
{
  fonts.fontconfig.enable = true; # Just in case it's not already enabled (should be)

  # Map all fonts to the fontconfig definitions
  programs.plasma.fonts = {
    general = {
      family = "Sans Serif";
      pointSize = 10;
    };

    fixedWidth = {
      family = "Monospace";
      pointSize = 10;
    };

    small = {
      family = "Sans Serif";
      pointSize = 8;
    };

    toolbar = {
      family = "Sans Serif";
      pointSize = 10;
    };

    menu = {
      family = "Sans Serif";
      pointSize = 10;
    };

    windowTitle = {
      family = "Sans Serif";
      pointSize = 10;
    };
  };
}
