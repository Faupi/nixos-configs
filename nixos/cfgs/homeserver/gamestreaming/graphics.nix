{ pkgs, ... }: {
  boot = {
    kernelModules = [
      "kvm-amd"
    ];
    kernelParams = [
      "amdgpu.virtual_display=0000:03:00.1,1" # Expose one virtual display
    ];
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
      extraPackages = with pkgs; [
        vulkan-loader
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];
}
