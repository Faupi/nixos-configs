{ pkgs, lib, ... }:
let
  regex = string: string; # Funny highlights
in
{
  programs.plasma.klipper = {
    syncClipboards = false;
    history = {
      keep = false;
      textSelection = "always";
      nontextSelection = "always";
    };
    actionsMenu = {
      showOnSelect = true;
      showOnHistory = false;
      trimWhitespace = true;
      includeMIME = true;
      excludeWindows = [ "*" ];
    };
    actions =
      let
        bash = lib.getExe pkgs.bash;
        curl = lib.getExe pkgs.curl;
        jq = lib.getExe pkgs.jq;
        htmlq = lib.getExe' pkgs.htmlq "htmlq";
        # yt-dlp = lib.getExe pkgs.yt-dlp;
        grep = lib.getExe pkgs.gnugrep;
      in
      {
        "Spotify link" = {
          automatic = true;
          regexp = regex ''^https?://open\.spotify\.com/(track|album)/([0-9|a-z|A-Z]+)'';
          commands = {
            "Play video" = {
              command = "${curl} https://api.song.link/v1-alpha.1/links/?url='%s' | ${jq} -j '.linksByPlatform.youtube.url' | ${grep} -Eo '^https://www.youtube.com/watch?v=[a-zA-Z0-9_-]{11}$$' | xargs mpv --profile=builtin-pseudo-gui --fs";
              icon = "mpv";
              output = "ignore";
            };
            "Copy YouTube link" = {
              command = "${curl} https://api.song.link/v1-alpha.1/links/?url='%s' | ${jq} -j '.linksByPlatform.youtube.url' | ${grep} -Eo '^https://www.youtube.com/watch\\?v=[a-zA-Z0-9_-]{11}$$'";
              icon = "youtube";
              output = "replace";
            };
            "Copy SongLink link" = {
              command = "${curl} https://api.song.link/v1-alpha.1/links/?url='%s' | ${jq} -j '.pageUrl'";
              icon = builtins.fetchurl {
                url = "https://odesli.co/favicon.ico";
                sha256 = "sha256:1xmv5k9258l6zilp6nxw69g63y7g0xpiisi5pw79wcpvf6l2y19a";
              };
              output = "replace";
            };
          };
        };
        "SongLink link" = {
          automatic = true;
          regexp = regex ''^https?://(song|album)\.link/\w+/'';
          commands = {
            "Open in Spotify" = {
              command = "${curl} https://api.song.link/v1-alpha.1/links/?url='%s' | ${jq} -j '.linksByPlatform.spotify.nativeAppUriDesktop' | xargs sh -c 'spotify --uri=$$1' sh";
              icon = "spotify";
              output = "ignore";
            };
            "Open in Spotify (better)" = {
              command = ''${curl} -s '%s' | ${htmlq} --text '#__NEXT_DATA__' | ${jq} -j '.props.pageProps.pageData.sections[] | select(.sectionId | test("links")?) | .links[] | select(.platform=="spotify") | .nativeAppUriDesktop' | xargs sh -c 'spotify --uri=$$1' sh'';
              icon = "spotify";
              output = "ignore";
            };
          };
        };

        "GitHub link" = {
          automatic = true;
          regexp = regex ''^https?://github\.com/'';
          commands = {
            "Copy Sourcegraph link" = {
              # TODO: Clean up - figure out a general solution (while being able to run scripts directly?)
              command = "${pkgs.substituteAll {
                src = ./github-sourcegraph.sh;
                inherit bash curl jq htmlq grep;
                isExecutable = true;
              }} '%s'";
              icon = builtins.fetchurl {
                url = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg";
                sha256 = "sha256:0s9g6i68kyljq13kh441fq79sszj5snqdz666c7msx7ncmv4x8q0";
              };
              output = "replace";
            };
          };
        };

        # "YouTube link" = {
        #   automatic = true;
        #   regexp = regex ''^https://(www\.youtube\.com/watch?v=|youtu\.be/)[a-zA-Z0-9_-]{11}$$'';
        #   commands = {
        #     "Download MP4" = {
        #       command =
        #         "${yt-dlp} --format mp4 --paths home:'~/Downloads/' -o - '%s'";
        #       icon = "YouTubeDownloader";
        #       output = "replace";
        #     };
        #   };
        # };
      };
  };
}
