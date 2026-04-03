{ ... }:
{
  boot.kernelParams = [
    "amd_pstate=active" # Should stabilize clocks (was boosting to max 4.2GHz)
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  services.hardware.openrgb.enable = true;
}
