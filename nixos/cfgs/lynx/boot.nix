{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest-lto-x86_64-v3;
    kernelParams = [
      # FIXME: Temporary flags to match Legion
      "amdgpu.sg_display=0"
      "amdgpu.dcdebugmask=0x10"

      "split_lock_detect=off"
      "preempt=full"
    ];
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
