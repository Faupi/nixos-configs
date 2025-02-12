{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    kernelModules = [
      "kvm-amd"
    ];
    kernelParams = [
      "video=eDP-1:panel_orientation=left_side_up" # Screen orientation
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

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  jovian.hardware.has.amd.gpu = true;

  # Auto-rotate
  hardware.sensor.iio.enable = true; # Sensors for ambient light and orientation | TODO: TEST
  environment.systemPackages = with pkgs; [
    iio-sensor-proxy
    kdePackages.qtsensors
  ];

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

  services = {
    fwupd.enable = true;
    xserver.videoDrivers = [ "amdgpu" ];
    power-profiles-daemon.enable = true; # CPU clocks, TDP, etc
  };

  powerManagement.enable = true; # Battery and general power management

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
