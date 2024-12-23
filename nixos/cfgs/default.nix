{ lib }:
let
  listConfigs = with builtins;
    dir:
    (lib.lists.foldr (n: col: col // n) { } (lib.attrsets.mapAttrsToList
      (name: type:
        let
          path = dir + "/${name}";
        in
        if name == "shared" then
        # nixosConfigs.shared.<configuration>
        # (import importer - inherit lib for it)
          {
            ${name} = (import path { inherit lib; });
          }
        else
        # nixosConfigs.<host>
          {
            ${name} = (import path);
          }
      )
      (readDir dir)));
in
listConfigs ./.
