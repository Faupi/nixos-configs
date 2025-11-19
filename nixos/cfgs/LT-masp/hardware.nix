{ pkgs, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "xe" ];

    # kernelParams = [
    #   # NOTE: these didn't do anything for blurry images
    #   # "i915.enable_psr=0"
    #   # "i915.enable_fbc=0"
    # ];

    initrd.luks.devices."nixmain".device = "/dev/disk/by-uuid/9674ab8d-e58c-4b73-8d76-9037799010a2";
  };

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;

  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.intel-media-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];

  swapDevices =
    [{
      device = "/.swapfile";
      size = 32 /*GB*/ * 1024;
    }];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
