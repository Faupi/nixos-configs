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
        # homeManagerConfigs.shared.<configuration>
          {
            ${name} = (import path { inherit lib; });
          }
        else
        # homeManagerConfigs.<user>
          {
            ${name} = (import path);
          }
      )
      (readDir dir)));
in
listConfigs ./.
