{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.clipboard-actions;
in
{
  options.flake-configs.clipboard-actions = {
    enable = mkEnableOption "Enable clipboard action configuration";
  };

  config = (mkIf cfg.enable {
    services.clipboardActions = {
      enable = true;

      rules =
        let
          openSpotifyLinkInApp = urlVar: /*sh*/''
            path=''${${urlVar}#https://open.spotify.com/}
            type=''${path%%/*}
            id=''${path#*/}
            id=''${id%%\?*}

            xdg-open "spotify:$type:$id"
          '';
        in
        [
          {
            name = "Any URL";
            regex = ''^https?://[^[:space:]]+\?[^[:space:]]+'';
            commands = [
              {
                label = "Clean URL";
                runtimeInputs = with pkgs; [ python3 ];
                command = "python3 ${./clean-url.py} '%s'";
                output = "copy";
              }
            ];
          }

          {
            name = "Spotify URL";
            regex = ''^https?://open\.spotify\.com/'';
            commands = [
              {
                label = "Copy JamShare link";
                runtimeInputs = with pkgs; [
                  curl
                  jq
                ];
                command = /*sh*/''
                  curl -fsS --get \
                    --data-urlencode "url=%s" \
                    --data "json=1" \
                    --data "src=web" \
                    'https://jamshare.app/api/share' |
                    jq -r '.share_url'
                '';
                output = "copy";
              }

              {
                label = "Open in Spotify";
                runtimeInputs = with pkgs; [
                  curl
                  libxml2
                  xdg-utils
                ];
                command = /*sh*/''
                  url='%s'
                  ${openSpotifyLinkInApp "url"}
                '';
                output = "ignore";
              }
            ];
          }

          {
            name = "JamShare URL";
            regex = ''^https?://jamshare.app/[^[:space:]]+'';
            commands =
              let
                getLinkFor = platform: /*sh*/''
                  curl -Ls '%s' | \
                    xmllint --html --xpath 'string(//a[img[@alt="${platform}"]]/@href)' -
                '';

                getSpotifyLink = getLinkFor "Spotify";
              in
              [
                {
                  label = "Copy Spotify link";
                  runtimeInputs = with pkgs; [
                    curl
                    libxml2
                  ];
                  command = getSpotifyLink;
                  output = "copy";
                }

                {
                  label = "Open in Spotify";
                  runtimeInputs = with pkgs; [
                    curl
                    libxml2
                    xdg-utils
                  ];
                  command = /*sh*/''
                    url="$(${getSpotifyLink})"
                    ${openSpotifyLinkInApp "url"}
                  '';
                  output = "ignore";
                }
              ];
          }

          {
            name = "YouTube URL";
            regex = ''^https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[^[:space:]]+'';
            commands = [
              {
                label = "Download MP4";
                runtimeInputs = with pkgs; [
                  xdg-user-dirs
                  ffmpeg
                  bleeding.yt-dlp-light
                ];
                command = /*sh*/''
                  filepath="$(yt-dlp --quiet --no-warnings --print after_move:filepath -t mp4 -P "$(xdg-user-dir DOWNLOAD)" '%s')" &&
                    wl-copy --type text/uri-list "file://$filepath" &&
                    notify-send --app-name="$APP_NAME" --transient \
                      "Copied downloaded MP4"
                '';
                output = "ignore";
              }
            ];
          }
        ];
    };
  });
}
