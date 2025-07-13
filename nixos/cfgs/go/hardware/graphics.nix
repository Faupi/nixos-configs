{ pkgs, ... }: {
  boot = {
    kernelModules = [
      "kvm-amd"
    ];
    kernelParams = [
      "video=eDP-1:panel_orientation=left_side_up" # Screen orientation
      "amdgpu.sg_display=0" # Disable scatter/gather - fixes white screen flashes https://www.phoronix.com/news/AMD-Scatter-Gather-Re-Enabled
      # GPU recovery is enabled globally on flake
    ];
  };

  jovian.hardware.has.amd.gpu = true;

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;

      # Keep AMDVLK disabled! Gamescope really dislikes it for some reason
      # - https://github.com/ValveSoftware/gamescope/issues/579
      # - https://github.com/ValveSoftware/gamescope/issues/1349
      amdvlk = {
        enable = false;
        support32Bit.enable = false;
      };
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
        lsfg-vk
      ];
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];
}
