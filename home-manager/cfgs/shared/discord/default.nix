{ config, pkgs, lib, fop-utils, ... }:
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
        package = fop-utils.wrapPkgBinary {
          inherit pkgs;
          package = pkgs.bleeding.discord; # 16/6/2026: Bleeding for latest patches like proper DMABUF support

          nameAffix = "hwaccel";

          variables = {
            # Target the system drivers if present (needed in case of system x home-manager mismatch)
            VK_ADD_DRIVER_FILES = {
              mode = "suffix";
              value = "/run/opengl-driver/share/vulkan/icd.d";
            };
          };
        };
      };

      # NOTE: If using vesktop, change path to `vesktop/themes/midnight.theme.css`
      # xdg.configFile."Vencord/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
    })
  ];
}
