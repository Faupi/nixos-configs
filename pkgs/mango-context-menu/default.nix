# Simple context menu binary that renders a Qt context menu using hooks from mango. Functions the same as your ordinary launcher, e.g. wofi.

{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "mango-context-menu";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    kdePackages.layer-shell-qt
  ];

  cmakeBuildType = "Release";
}
