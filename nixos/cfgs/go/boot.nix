{ config, lib, pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    extraModulePackages = with config.boot.kernelPackages; [
      zenpower
    ];

    initrd.availableKernelModules = [
      "amdgpu"
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "rtsx_pci_sdmmc"
    ];
    blacklistedKernelModules = [
      "k10temp" # Replaced by zenpower
    ];
    kernelModules = [
      "zenpower" # Better sensor reads on linux_zen
      "msr"
    ];

    loader = {
      # TODO: Find a reasonable way to use the bootloader menu without the need for peripherals
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
    };

    # Enable SysRq (REISUB)
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
