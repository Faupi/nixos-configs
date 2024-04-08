{ lib, mkDirectDesktopItem, stdenvNoCC }:
{ name
, exec
, delay ? 0
, ...
}@desktopArgs:
let
  renderedArgs =
    desktopArgs
    // {
      noDisplay = true;
    }
    // (lib.attrsets.optionalAttrs (delay > 0) {
      # Add a 5 second delay because of task icon resolution loading problems on KDE
      exec = ''sh -c "sleep ${toString delay} && ${desktopArgs.exec}"'';
    });

  desktopItem = mkDirectDesktopItem renderedArgs;
in
stdenvNoCC.mkDerivation {
  name = "autostart-${name}";

  dontUnpack = true;
  dontConfigure = true;
  buildInputs = [ desktopItem ];

  buildCommand = ''
    cp ${desktopItem} $out/etc/xdg/autostart/
  '';
}
