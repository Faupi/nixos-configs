{ pkgs, ... }: {
  active-accent-decorations = pkgs.callPackage ./active-accent-decorations { };
  html-wallpaper = pkgs.callPackage ./html-wallpaper.nix { };
  onedark = pkgs.callPackage ./onedark.nix { };
  panon = pkgs.callPackage ./panon.nix { };
}
