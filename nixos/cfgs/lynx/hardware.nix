{ config, pkgs, ... }:
{
  boot = {
    kernelParams = [
      "amd_pstate=active" # Should stabilize clocks (was boosting to max 4.2GHz)
    ];

    kernelModules = [ "zenpower" ];
  };

  hardware = {
    firmware = [ pkgs.bleeding.linux-firmware ]; # Up to date drivers for GPU
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  services.hardware.openrgb.enable = true;
}
