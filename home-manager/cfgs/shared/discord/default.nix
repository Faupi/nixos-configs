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
        (SOCIALS.discord.override { withVencord = true; })
      ];

      xdg.configFile."vesktop/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
    })
  ];
}
