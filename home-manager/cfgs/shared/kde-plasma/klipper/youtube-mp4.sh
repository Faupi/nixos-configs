#!@bash@

@ytdlp@ --paths "$HOME/Downloads" -o "%(id)s.%(ext)s" --print after_move:filepath --format mp4 --no-playlist "$1" |
  xargs -I {} @wlcopy@ --type text/uri-list file://{}
