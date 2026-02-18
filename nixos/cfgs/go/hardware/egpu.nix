# Thunderbolt-connected eGPU configuration
# Hardware: Minisforum DEG2 + GIGABYTE GeForce RTX 3070 Vision OC 8G

# TODO: Auto-disable LSFG for the time being while eGPU is connected to avoid backfeeding

{ config, ... }: {
  boot = {
    # Blacklist nouveau to avoid falling back to it
    blacklistedKernelModules = [ "nouveau" ];

    kernelParams = [
      # Enable AMD IOMMU, required for stable Thunderbolt eGPU DMA mapping
      # iommu=pt keeps performance overhead minimal.
      "amd_iommu=on"
      "iommu=pt"

      /*
        Disable NVIDIA GSP firmware - IMPORTANT
        Required for stability with Ampere (RTX 3070) over Thunderbolt eGPU.
        With GSP enabled, Wayland/KMS initialization can hard-freeze or
          produce Xid errors on this hardware.
      */
      "nvidia.NVreg_EnableGpuFirmware=0"
    ];
  };

  # Thunderbolt
  services.hardware.bolt.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Actual graphics
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false; # Proprietary driver required; open-source drivers really don't work for my case here
    nvidiaSettings = true;
    modesetting.enable = true;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      /*
        Refresh bus IDs with `lspci | grep -E "VGA|3D"`
        First field is hex bus number, needs to be converted to decimal
        Format required by PRIME: `PCI:<bus>@0:<device>:<function>`
          (it's actually PCI:<bus>@<domain>:... but domain is pretty much always 0)
        e.g. `c2:00.0` -> `PCI:194@0:0:0`

        If these are wrong, PRIME offload will fail and display manager may not start, 
          leading to boot loops, which of course is no bueno
      */
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


# I'm only commenting all of this because it was a pain in the ass and I know I will forget it all
