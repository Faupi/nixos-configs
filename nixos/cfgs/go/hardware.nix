{ config, lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    kernelModules = [
      "kvm-amd"
      "acpi_call" # TDP control in HHD
    ];
    kernelParams = [
      "video=eDP-1:panel_orientation=left_side_up" # Screen orientation
      "amdgpu.gttsize=4096" # NOTE: Bazzite uses 8128
      "iomem=relaxed" # ryzenadj / SimpleDeckyTDP compat
      "spi_amd.speed_dev=1" # TODO: Exp.
      "amdgpu.sg_display=0" # Disable scatter/gather - fixes white screen flashes https://www.phoronix.com/news/AMD-Scatter-Gather-Re-Enabled
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

    loader = {
      timeout = 0; # Can't interact with it using the controller anyway. Dual-booting is preferable via the hardware boot menu
      systemd-boot = {
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
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    bluetooth = {
      enable = true;
      disabledPlugins = [ "sap" ];
    };
  };

  jovian.hardware.has.amd.gpu = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  powerManagement.enable = true;

  services = {
    fwupd.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };

  # SD Card
  fileSystems."/mnt/sd-card" = {
    # https://github.com/Jovian-Experiments/Jovian-NixOS/issues/321#issuecomment-2212392814
    device = "/dev/mmcblk0p1";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.automount"
    ];
  };
}
