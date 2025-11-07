{ pkgs, ... }: {
  MickaelBlet.highlight-regex = pkgs.callPackage ./highlight-regex { };
  eclairevoyant.eel = pkgs.callPackage ./eel { };
}
