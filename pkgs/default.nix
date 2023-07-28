{ lib, pkgs }:
let
  listPackagesRecursive = with builtins;
    dir:
    (lib.lists.foldr (n: col: col // n) { } (lib.attrsets.mapAttrsToList
      (name: type:
        let 
          path = dir + "/${name}";
        in if type == "directory" then
          let 
            pathDefault = (path + "/default.nix");
          in if builtins.pathExists pathDefault then
            { "${name}" = pkgs.callPackage pathDefault { }; }
          else
            listPackagesRecursive path
        else
          let 
            nixTrim = (substring 0 ((stringLength name)-4) name);
            nixExtension = (substring ((stringLength name)-4) (stringLength name) name);
          in if name != "default.nix" && nixExtension == ".nix" then
            { "${nixTrim}" = pkgs.callPackage path { }; }
          else 
            { }
      )
      (builtins.readDir dir)));
in
listPackagesRecursive ./.
