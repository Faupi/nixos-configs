{ config, pkgs, inputs, lib, ... }:
let
  cfg = config.flake-configs.maliit-keyboard;
in
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  options.flake-configs.maliit-keyboard = {
    enable = lib.mkEnableOption "Maliit keyboard";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      maliit-framework
      maliit-keyboard
    ];

    programs.plasma.configFile.kwinrc.Wayland = {
      InputMethod = "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
      VirtualKeyboardEnabled = true;
    };

    dconf = {
      enable = true;
      settings = {
        "org.maliit.keyboard.maliit" = {
          key-press-haptic-feedback = true;
          theme = "BreezeDark";
        };
      };
    };
  };
}
