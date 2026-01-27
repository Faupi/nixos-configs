{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest; # Always the latest kernel
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
        editor = false; # Prevent 'e' from editing entries
        consoleMode = "1";
      };
      timeout = 0; # Mostly to skip on hibernation - hold ESC while booting instead
    };

    # Enable SysRq (REISUB)
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
