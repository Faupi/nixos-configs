{ pkgs, ... }: {
  boot = {
    kernelModules = [
      "kvm-amd"
    ];
    kernelParams = [
      "video=eDP-1:panel_orientation=left_side_up" # Screen orientation
      "amdgpu.sg_display=0" # Disable scatter/gather - fixes white screen flashes https://www.phoronix.com/news/AMD-Scatter-Gather-Re-Enabled
    ];
  };

  jovian.hardware.has.amd.gpu = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
}
