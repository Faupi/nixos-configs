{ pkgs, ... }: {
  home.packages = with pkgs; [
    kde-bismuth # Custom packaging -> pkgs/kde-bismuth/default.nix
  ];
}
