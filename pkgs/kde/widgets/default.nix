{ pkgs, ... }: {
  fokus = pkgs.callPackage ./fokus { };
  panon = pkgs.callPackage ./panon { };
  plasma-drawer = pkgs.callPackage ./plasma-drawer { };
  plasmoid-button = pkgs.callPackage ./plasmoid-button { };
}
