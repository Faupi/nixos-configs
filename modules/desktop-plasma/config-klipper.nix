{ config, pkgs, lib, ... }:
{
  plasmashellrc = {
    Action_0 = {
      Automatic = true;
      Description = "Spotify link";
      # "Number of commands" = 3;
      Regexp = ''^https?://open\\.spotify\\.com/(track|album)/([0-9|a-z|A-Z]+)''
    };

    "Action_0/Command_0" = {
      "Commandline[$e]" = ''curl https://api.song.link/v1-alpha.1/links/?url='%s' | jq -j '.linksByPlatform.youtube.url' | grep -Eo '^https://www.youtube.com/watch\\?v=[a-zA-Z0-9_-]{11}$$' | xargs mpv --profile=builtin-pseudo-gui --fs'';
      Description = "Play video";
      Enabled = true;
      Icon = "mpv";
      Output = 0;
    };
  };
}
