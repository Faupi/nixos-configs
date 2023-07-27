{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith pkgs;
in
{
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix { };
}
