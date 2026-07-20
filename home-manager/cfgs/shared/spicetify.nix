{ pkgs, ... }: {
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify.overrideAttrs (old: rec {
      version = "1.2.92.147.g5b8f9367";
      rev = "97";
      src = pkgs.fetchurl {
        name = "spotify-${version}-${rev}.snap";
        url = "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_${rev}.snap";
        hash = "sha256-mKkxAXNWOWW+XNMGslohmCP5wNqAn9qb9Ro0yWOFeNA=";
      };
    });
    wayland = true; # Wayland Spotify doesn't have proper titlebars anywhere outside of KDE

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
