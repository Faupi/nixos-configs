# mkDolphinServiceMenu.nix
{ pkgs, lib, ... }:

{ name
, title
, script
, icon ? null
, mimeTypes ? [ ]
, extraDesktopConfig ? { }
}:
let
  renderValue = v:
    if builtins.isList v then
      "${lib.concatStringsSep ";" v};"
    else
      toString v;

  renderLine = k: v:
    "${k}=${renderValue v}";

  extraLines =
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList renderLine extraDesktopConfig);
in
pkgs.writeTextFile {
  name = "${name}-servicemenu";
  destination = "/share/kio/servicemenus/${name}.desktop";
  text = ''
    [Desktop Entry]
    Type=Service
    X-KDE-ServiceTypes=KonqPopupMenu/Plugin
    MimeType=${builtins.concatStringsSep ";" mimeTypes};
    Actions=${name};
    ${extraLines}

    [Desktop Action ${name}]
    Name=${title}
    Exec=${script} %F
    Icon=${icon}
  '';
}
