{ config, lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.tmp.tmpfsSize = "64G";

  swapDevices =
    [{
      device = "/.swapfile";
      size = 128 /*GB*/ * 1024;
    }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
