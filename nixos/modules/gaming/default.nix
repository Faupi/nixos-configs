{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    libstrangle
    mangohud
  ];

  services.lsfg-vk = {
    enable = true;
    ui.enable = true;
    package = pkgs.lsfg-vk;
  };

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
}
