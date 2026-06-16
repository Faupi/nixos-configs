{ pkgs, ... }: {
  boot = {
    # REVIEW: Stock kernel and console suspend for suspend shutdown testing
    # kernelPackages = pkgs.linuxKernel.packagesFor pkgs.cachyosKernels.linux-cachyos-latest-lto-x86_64-v3;
    # Zenpower patch needed for cachyOS kernel
    # extraModulePackages = [
    #   (config.boot.kernelPackages.zenpower.overrideAttrs (old: {
    #     nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    #       pkgs.llvmPackages.clang-unwrapped
    #     ];

    #     makeFlags = (old.makeFlags or [ ]) ++ [
    #       "CC=${pkgs.llvmPackages.clang-unwrapped}/bin/clang"
    #     ];
    #   }))
    # ];
    kernelParams = [
      "no_console_suspend"
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
