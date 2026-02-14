/* 
  Thunderbolt-connected eGPU configuration
  Hardware: Minisforum DEG2 + GIGABYTE GeForce RTX 3070 Vision OC 8G
*/
# TODO: Auto-disable LSFG for the time being, when eGPU is connected to avoid backfeeding

{ config, ... }: {
  boot.kernelParams = [
    # Enable IOMMU, generally better security, but enables external PCIe
    "amd_iommu=on"
    "iommu=pt"

    # Disable NVIDIA GSP firmware.
    # Ampere GPUs default to using GSP, which moves parts of the
    # driver into firmware running on the GPU.
    # TODO: Test if it's absolutely needed
    "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  services.hardware.bolt.enable = true;
  hardware.enableRedistributableFirmware = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      amdgpuBusId = "PCI:194@0:0:0"; # iGPU
      nvidiaBusId = "PCI:101@0:0:0"; # eGPU

      allowExternalGpu = true;

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };
}
