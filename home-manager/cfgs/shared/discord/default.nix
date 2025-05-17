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
        (discord.override { withVencord = true; vencord = pkgs.bleeding.vencord; })
      ];

      # NOTE: Change path to vesktop if using that client
      xdg.configFile."Vencord/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
    })
  ];
}
