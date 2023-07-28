{ pkgs }: {
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge.nix { };
  plasmadeck = pkgs.callPackage ./plasmadeck.nix { };
}
