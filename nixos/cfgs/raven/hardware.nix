{ pkgs, ... }:
{
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "usb_storage"
        "sd_mod"
      ];

      # Load USB modules specifically as the laptop never requests them - make USB keyboard work early
      kernelModules = [
        "xhci_pci"
        "usbhid"
      ];
    };

    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "xe" ];

    initrd.luks.devices."nixmain".device = "/dev/disk/by-uuid/9674ab8d-e58c-4b73-8d76-9037799010a2";
  };

  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.intel-media-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];

  swapDevices =
    [{
      device = "/var/lib/swapfile";
      size = 32 /*GB*/ * 1024;
    }];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
