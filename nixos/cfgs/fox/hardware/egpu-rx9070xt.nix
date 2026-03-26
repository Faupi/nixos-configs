# Thunderbolt-connected eGPU configuration
# Hardware: Minisforum DEG2 + SAPPHIRE RX 9070 XT 16GB OC

# I'm leaving it here as a testament of the 40 hours or so of trying to get this shit to work. I give up. AMD on Thunderbolt 4 seems just too unstable. Even on 7.0-rc3

{ lib, pkgs, ... }: {
  boot = {
    # Preload thunderbolt early
    initrd.kernelModules = [
      "thunderbolt"
    ];
    kernelParams = [
      # "amd_iommu=on" # apparently this is not a real thing and throws errors
      #"iommu=pt"

      # "pci=noats" # ATS is necessary for GPU init at all

      # "pcie_ports=native" # DO NOT ENABLE - seems to cause periodic resets
      #"pci=pcie_bus_safe,noaer"
      #"amdgpu.msi=0"
      # TODO: pci=assign-busses

      # Disable unsupported features (mostly log spam by the looks of it)
      # "amdgpu.mes=0"
      "amdgpu.gfxoff=0"
      # "amdgpu.dpm=0" # DO NOT DISABLE - DPM enabled is NECESSARY for the GPU to initialize (even if it disables itself afterwards)
      #"amdgpu.rebar=0" # Can't resize it anyway

      #"pcie_aspm=off"
      #"pcie_port_pm=off"

      # We want SDMA disabled but this is still not enough
      #"amdgpu.sdma=0"
      #"amdgpu.sdma_phase_quantum=0" # This is the only real one

      # Prevent resets?
      # "amdgpu.noretry=0"
      "amdgpu.lockup_timeout=10000"
      # "amdgpu.lockup_timeout=-1"

      # PCIE is bs here, it just causes issues
      # "amdgpu.pcie_gen_cap=1"
      # "amdgpu.pcie_lane_cap=4"

      #"vm_update_mode=3" # CPU take over

      # "amdgpu.pcie_p2p=0" # Disable large direct transfers over PCIe - avoid hangs
      # "amdgpu.pcie_gen2=0"
    ];
    extraModprobeConfig = lib.concatStringsSep "\n" [
      "softdep amdgpu pre: thunderbolt"
      "options amdgpu pcie_gen_cap=0x40000" # Limit to gen3
      # "options amdgpu pcie_gen_cap=0x10000"

      "options thunderbolt host_reset=0"
    ];
  };

  # Thunderbolt
  services.hardware.bolt.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Actual graphics
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    # package = pkgs.bleeding.mesa;
    # package32 = pkgs.bleeding.pkgsi686Linux.mesa;
  };
  hardware.firmware = [ pkgs.bleeding.linux-firmware ];
}

