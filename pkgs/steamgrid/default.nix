{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "steamgrid-${version}";
  version = "unstable-2023-04-20";

  goPackagePath = "github.com/boppreh/steamgrid";

  src = fetchgit {
    url = "https://github.com/boppreh/steamgrid";
    rev = "cd672e44ab11284202d1d66fba0bcb1b6589078b";
    sha256 = "1xldiln6mh2rzlak9xdfhq05h58wg3h3bys7n728p3x9ymd9xw4r";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Downloads images to fill your Steam grid view";
    downloadPage = "https://github.com/boppreh/steamgrid/releases";
    homepage = "https://github.com/boppreh/steamgrid";
    license = licenses.mit;
    longDescription = ''
      SteamGrid is a standalone, fire-and-forget program to enhance Steam's grid view and Big Picture. It preloads the banner images for all your games (even non-Steam ones) and applies overlays depending on your categories.

      You run it once and it'll set up everything above, automatically, keeping your existing custom images. You can run again when you get more games or want to update the category overlays.
    '';
    platforms = platforms.unix;
  };
}