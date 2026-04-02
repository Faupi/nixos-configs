{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest-lto-x86_64-v3;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];

    ntsync.enable = true;
    tmp.tmpfsSize = "64G";

    loader.systemd-boot.memtest86.enable = true;
  };
}
