{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.flake-configs.discord;
in
{
  options.flake-configs.discord = {
    enable = mkEnableOption "Enable Discord";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        equibop
      ];

      # NOTE: If using vesktop, change path to `vesktop/themes/midnight.theme.css`
      # xdg.configFile."Vencord/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
    })
  ];
}
