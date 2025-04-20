{ pkgs, ... }: {
  themes = pkgs.callPackage ./themes { };

  active-accent-decorations = pkgs.callPackage ./active-accent-decorations { };
  html-wallpaper = pkgs.callPackage ./html-wallpaper.nix { };
  panon = pkgs.callPackage ./panon.nix { };
}
