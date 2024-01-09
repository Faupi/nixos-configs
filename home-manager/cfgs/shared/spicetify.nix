{ pkgs, ... }: {
  programs.spicetify = {
    enable = true;
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
    ];

    enabledCustomApps = with pkgs.spicetify-extras.apps; [
      new-releases
    ];
  };
}
