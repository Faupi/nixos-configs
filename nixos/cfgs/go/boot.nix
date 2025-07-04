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
      timeout = 0; # Can't interact with it using the controller anyway. Dual-booting is preferable via the hardware boot menu
      # Disable systemd-boot, as it holds onto old generations - TODO: Apply globally if it works
      systemd-boot = {
        enable = lib.mkForce false;
        consoleMode = "max";
      };
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        gfxmodeEfi = "768x1024x32"; # 1024x1280x32
        timeoutStyle = "hidden";
      };
    };

    # Enable SysRq (REISUB)
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
