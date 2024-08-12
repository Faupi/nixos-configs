{ pkgs, ... }: {
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.SOCIALS.spotify;

    theme = pkgs.spicetify-extras.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with pkgs.spicetify-extras.extensions; [
      fullAppDisplay
      shuffle
      trashbin
      hidePodcasts
      adblock
      volumePercentage
      history
      autoSkip
    ];

    enabledCustomApps = with pkgs.spicetify-extras.apps; [
      newReleases
      lyricsPlus
      marketplace
    ];
  };
}
