{ pkgs, lib, ... }:
let
  inherit (pkgs)
    stdenvNoCC
    kdePackages
    writeText
    ;

  searchPath = "share/kf6/searchproviders";

  dummy = writeText "disabled-searchprovider-dummy" (lib.generators.toINI { } {
    "Desktop Entry" = {
      Hidden = true;
      Type = "Service";
    };
  });
in
stdenvNoCC.mkDerivation {
  name = "plasma-disable-default-web-search";

  dontWrapQtApps = true;
  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    mkdir -p $out/${searchPath}

    ls ${kdePackages.kio.out}/${searchPath}/*.desktop | 
      xargs -n 1 basename | 
      while read f; do
        cp ${dummy} $out/${searchPath}/$f
      done
  '';
}
