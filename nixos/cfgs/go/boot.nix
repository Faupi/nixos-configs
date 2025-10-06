{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # extraModulePackages = with config.boot.kernelPackages; [ ];

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
      "zenpower" # Avoid potential conflicts with k10temp
    ];
    kernelModules = [
      "msr"
      "k10temp" # Proper temperature monitoring (for e.g. MangoHud)
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
