{ pkgs, ... }: {
  plugins = pkgs.callPackage ./plugins { };
}
