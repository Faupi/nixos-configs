{ fetchzip }:
fetchzip {
  url = "https://github.com/itsOwen/playcount-decky/releases/download/playcount-decky-v1.6/playcount-v1.6.zip";
  sha256 = "sha256-u+oZ+rR4dk7qsRaA8asCFj17Xz/qxPJ/nPzErHPZNuM=";
  stripRoot = false;
  extension = "zip";
}
