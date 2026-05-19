{ config, pkgs, ... }:
{
  boot = {
    kernelParams = [
      "amd_pstate=active" # Should stabilize clocks (was boosting to max 4.2GHz)
    ];

    extraModulePackages = [
      (config.boot.kernelPackages.zenpower.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
          pkgs.gcc
        ];
      }))
    ];
    kernelModules = [ "zenpower" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  services.hardware.openrgb.enable = true;
}
