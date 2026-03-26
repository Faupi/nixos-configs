{ pkgs, ... }: {
  environment = {
    sessionVariables = {
      PROTON_FSR4_UPGRADE = 1; # FSR 3.1+ gets upgraded to FSR4 
      ENABLE_LAYER_MESA_ANTI_LAG = 1; # Improves latency (mesa 25.3+)
    };
    systemPackages = with pkgs; [
      amdgpu_top
      libva-utils
      vulkan-tools
    ];
  };

  boot = {
    kernelModules = [
      "amdgpu"
    ];
    # kernelParams = [
    #   "amdgpu.virtual_display=0000:03:00.0,1" # Expose one virtual display
    # ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
