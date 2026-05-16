{ pkgs, lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.flake-configs.gaming;
in
{
  options.flake-configs.gaming = {
    enable = mkEnableOption "Gaming utilities";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mangohud
      libstrangle # Genuinely great at working around some games having broken VSync

      # (pkgs.lsfg-vk_2.override { buildUI = true; })
      lsfg-vk
      lsfg-vk-ui
    ];

    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };

        # Warning: GPU optimisations have the potential to damage hardware
        gpu = {
          apply_gpu_optimisations = "accept-responsibility"; # For systems with AMD GPUs
          gpu_device = 0;
          amd_performance_level = "high";
        };

        custom =
          let
            notify = lib.getExe pkgs.libnotify;
          in
          {
            start = "${notify} 'GameMode started'";
            end = "${notify} 'GameMode ended'";
          };
      };
    };
  };
}
