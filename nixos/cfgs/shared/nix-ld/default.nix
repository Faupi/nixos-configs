{ config, lib, pkgs, ... }:
let
  cfg = config.flake-configs.nix-ld;
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) callPackage;

  libraries = {
    deadZoneRevive = callPackage ./libraries/dead-zone-revive.nix { };
  };
in
{
  options.flake-configs.nix-ld = {
    enable = mkEnableOption "Enable config set for nix-ld";
    useLibraries.deadZoneRevive = mkEnableOption "Dead Zone Revive library set";
  };

  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;

      # Initial minimal set
      libraries = (with pkgs; [
        alsa-lib
        dbus
        fontconfig
        freetype
        glib
        libdrm
        libgcc
        libx11
        libxcb
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        mesa
        openssl
      ])
      ++ lib.lists.optionals cfg.useLibraries.deadZoneRevive libraries.deadZoneRevive;
    };
  };
}
