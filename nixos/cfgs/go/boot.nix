{ lib, pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
    kernelParams = [ "fbcon=rotate:3" "video=eDP-1:panel_orientation=left_side_up" ];

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
        timeoutStyle = "hidden";
        extraConfig = ''
          fbcon=rotate:1
        '';
      };
    };

    # Enable SysRq (REISUB)
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
