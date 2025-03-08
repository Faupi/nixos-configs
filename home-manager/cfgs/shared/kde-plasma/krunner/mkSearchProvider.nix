# NOTE: Use `\\{@}` as placeholder in URL
{ pkgs, lib, ... }: {
  mkSearchProvider = { name, url, keywords ? [ ] }:
    let
      searchPath = "share/kf6/searchproviders";
      desktopFile = pkgs.writeText "searchprovider-${name}" (lib.generators.toINI { } {
        "Desktop Entry" = {
          Hidden = false;
          Keys = lib.strings.concatStringsSep "," keywords;
          Name = name;
          Query = url;
          Type = "Service";
        };
      });
    in
    pkgs.stdenvNoCC.mkDerivation {
      name = "searchprovider-${name}";

      dontWrapQtApps = true;
      dontUnpack = true;
      dontConfigure = true;

      buildPhase = ''
        mkdir -p $out/${searchPath}

        ln -s ${desktopFile} $out/${searchPath}/${name}.desktop
      '';
    };
}
