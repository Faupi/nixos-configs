{ pkgs, ... }: {
  plugins = pkgs.callPackage ./plugins { };
  themes = pkgs.callPackage ./themes { };
  widgets = pkgs.callPackage ./widgets { };

  active-accent-decorations = pkgs.callPackage ./active-accent-decorations { };
}
