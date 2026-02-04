{ pkgs, cfg, lib, ... }:
let
  package = pkgs.kdePackages.plasma-keyboard;
in
{
  options.flake-configs.plasma.virtualKeyboard = {
    enable = lib.mkEnableOption "Virtual keyboard config";
  };

  config = lib.mkIf cfg.virtualKeyboard.enable {
    home.packages = [ package ];

    programs.plasma.configFile.kwinrc.Wayland = {
      InputMethod = "${package}/share/applications/org.kde.plasma.keyboard.desktop";
      VirtualKeyboardEnabled = true;
    };
  };
}
