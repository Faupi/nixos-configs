{ pkgs, inputs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkMerge getExe;
  cfg = config.flake-configs.spotify;

in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.flake-configs.spotify = {
    enable = mkEnableOption "Spotify configuration";
    autoStart = mkEnableOption "Auto-start";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.spicetify = {
        enable = true;
        spotifyPackage = pkgs.spotify;
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
    })

    # TODO: fix autostart so it starts with spicetify - currently starts vanilla
    (mkIf (cfg.enable && cfg.autoStart) {
      home.packages = [
        (pkgs.makeAutostartItem rec {
          name = "spotify";
          package = pkgs.makeDesktopItem {
            inherit name;
            desktopName = "Spotify";
            icon = "spotify";
            exec = getExe config.programs.spicetify.spotifyPackage;
          };
        })
      ];
    })
  ];
}
