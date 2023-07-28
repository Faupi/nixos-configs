{ lib, pkgs }:
let
  listPackages = with builtins;
    dir:
    (lib.lists.foldr (n: col: col // n) { } (lib.attrsets.mapAttrsToList
      (fullName: type:
        let 
          path = dir + "/${fullName}";
        in if type == "directory" then
          # Load directory with default.nix
          let 
            pathDefault = (path + "/default.nix");
          in if builtins.pathExists pathDefault then
            { "${fullName}" = pkgs.callPackage pathDefault { }; }
          else
            { }
        else
          # Load *.nix
          let 
            nameExtSplit = (match "(^.+)\\.(.+)$" fullName);
            hasExtension = (length nameExtSplit) == 2;
          in if hasExtension then
            let
              name = elemAt nameExtSplit 0;
              extension = elemAt nameExtSplit 1;
            in if fullName != "default.nix" && extension == "nix" then
              { "${name}" = pkgs.callPackage path { }; }
            else 
              { }
          else
            { }
      )
      (builtins.readDir dir)));
in
listPackages ./.
