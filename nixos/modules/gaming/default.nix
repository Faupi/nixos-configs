{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    libstrangle
    mangohud
  ];

  hardware.graphics.extraPackages = with pkgs; [
    lsfg-vk # Lossless Scaling
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
