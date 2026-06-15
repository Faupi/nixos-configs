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
      programs.discord = {
        enable = true;
        package = pkgs.bleeding.discord; # 16/6/2026: Bleeding for latest patches like proper DMABUF support
      };

      # NOTE: If using vesktop, change path to `vesktop/themes/midnight.theme.css`
      # xdg.configFile."Vencord/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
    })
  ];
}
