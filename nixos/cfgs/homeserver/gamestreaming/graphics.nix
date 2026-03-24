{ pkgs, ... }: {
  boot = {
    kernelModules = [
      "kvm-amd"
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
