{ ... }@static-args: {
  faupi = { config, lib, pkgs, ... }@home-args:
    (import ./faupi.nix (home-args // static-args));
}
