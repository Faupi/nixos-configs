{ pkgs, ... }: {
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify;
    wayland = true;

    theme = pkgs.spicetify-extras.themes.sleek;
    colorScheme = "UltraBlack";

    enabledExtensions = with pkgs.spicetify-extras.extensions; [
      fullAppDisplay
      volumePercentage
    ];

    enabledCustomApps = with pkgs.spicetify-extras.apps; [
      newReleases
      lyricsPlus
      marketplace
    ];

    enabledSnippets = with pkgs.spicetify-extras.snippets; [
      removeTopSpacing
      pointer
      removePopular
      hideDownloadButton
      modernScrollbar
    ];
  };
}
