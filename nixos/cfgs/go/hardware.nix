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
        consoleMode = "max";
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
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  # HHD
  users.users.hhd = {
    group = "hhd";
    home = "/var/lib/handheld-daemon";
    createHome = true;
    isSystemUser = true;
  };
  users.groups.hhd = { };

  services.handheld-daemon = {
    enable = true;
    user = "hhd";
    ui.enable = true;
    adjustor = {
      enable = true;
      acpiCall.enable = true;
    };
  };

  # Let adjustor handle it via power-profiles-daemon
  powerManagement.enable = false;

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
