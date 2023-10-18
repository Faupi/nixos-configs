{ ... }@static-args: {
  faupi = { pkgs, ... }@home-args: {
    imports = [ (import ./faupi.nix (home-args // static-args)) ];
  };
}
