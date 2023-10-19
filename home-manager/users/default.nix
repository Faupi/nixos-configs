{ fop-utils, ... }@static-args:
let
  mkUser = name: {
    "${name}" = { config, lib, pkgs, ... }@home-args:
      (fop-utils.recursiveMerge [
        {
          home = {
            username = name;
            homeDirectory = "/home/${name}";
            stateVersion = "23.05";
          };
        }
        (import ./faupi.nix (home-args // static-args))

      ]);
  };
in (fop-utils.recursiveMerge [
  (mkUser "faupi")

])
