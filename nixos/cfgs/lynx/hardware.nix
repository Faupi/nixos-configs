{ ... }:
{
  boot.kernelModules = [
    "kvm-intel" # TODO: Remove after switch
    "kvm-amd"
  ];

  powerManagement.cpuFreqGovernor = "performance";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true; # TODO: Remove after switch
    cpu.amd.updateMicrocode = true;
  };
}
