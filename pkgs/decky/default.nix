{ pkgs, ... }: {
  plugins = pkgs.callPackage ./plugins { };
  themes = pkgs.callPackage ./themes { };
}
