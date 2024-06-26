{ lib, ... }:
let
  listModules = dir:
    (lib.lists.foldr (n: col: col // n) { } (lib.attrsets.mapAttrsToList
      (fullName: type:
        let
          path = dir + "/${fullName}";
        in
        if type == "directory" then
        # Load directory with default.nix
          if builtins.pathExists (path + "/default.nix") then
            { "${fullName}" = (import path); }
          else
            { }
        else
        # Load *.nix
          let
            nameExtSplit = (builtins.match "(^.+)\\.(.+)$" fullName);
            hasExtension = (builtins.length nameExtSplit) == 2;
          in
          if hasExtension then
            let
              name = builtins.elemAt nameExtSplit 0;
              extension = builtins.elemAt nameExtSplit 1;
            in
            if fullName != "default.nix" && extension == "nix" then
              { "${name}" = (import path); }
            else
              { }
          else
            { }
      )
      (builtins.readDir dir)));
in
listModules ./.
