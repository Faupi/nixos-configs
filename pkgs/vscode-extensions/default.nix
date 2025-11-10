{ pkgs, ... }: {
  BeardedBear.bearded-theme = pkgs.callPackage ./bearded-theme { };
  eclairevoyant.eel = pkgs.callPackage ./eel { };
  MickaelBlet.highlight-regex = pkgs.callPackage ./highlight-regex { };
}
