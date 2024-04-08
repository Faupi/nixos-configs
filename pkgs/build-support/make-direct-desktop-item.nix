# Function to create a direct link to a desktop item
{ lib, makeDesktopItem, stdenvNoCC }:
{ name
, ...
}@desktopArgs:
let
  desktopItem = makeDesktopItem desktopArgs;
in
stdenvNoCC.mkDerivation {
  name = "direct-${name}";
  buildInputs = [ desktopItem ];
  buildCommand = ''
    "cp ${desktopItem}/share/applications/${name}.desktop $out"
  '';
}
