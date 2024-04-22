{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
    kernelModules = [ "kvm-amd" ];

    initrd.availableKernelModules = [
      "acpi_call" # TDP control in HHD
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
      "rtsx_pci_sdmmc"
    ];

    loader.systemd-boot = {
      enable = true;
      # SOURCE: https://github.com/appsforartists/device-config/blob/611b066d2afd8d5b53727211c4615439b4dc7d32/hosts/go/configuration.nix#L34-L48
      # "1" fixes the orientation, but the text is unfortunately small.
      # "max" also fixes the orientation, but stretches the text to fill the screen.
      # The text is clipped no matter which option you choose.
      consoleMode = "max";
      # Docs say to turn this off on modern systems for a more secure setup.
      editor = false;
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    bluetooth = {
      enable = true;
      disabledPlugins = [ "sap" ];
    };
  };

  jovian.hardware.has.amd.gpu = true;

  powerManagement.enable = true;

  services = {
    fwupd.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
  };

  swapDevices = [
    {
      device = "/.swapfile";
      size = 16 /*GB*/ * 1024;
    }
  ];
}
