{ fetchzip }:
fetchzip {
  url = "https://github.com/itsOwen/playcount-decky/releases/download/playcount-decky-v1.7/PlayCount.zip";
  sha256 = "sha256-IxiC4hX7KA8tXzYjjwIZvd/JBbQ3rp/hyXeW6iV30Lo=";
  stripRoot = false;
  extension = "zip";
}
