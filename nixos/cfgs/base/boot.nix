{ lib, fop-utils, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelParams = [
      "boot.shell_on_fail" # Enable shell on boot failure
    ];
    extraModprobeConfig = lib.concatStringsSep "\n" [
      "options amdgpu gpu_recovery=1" # Tries to recover GPU on hangs - might be needed for Plasma sleep hangs!
      "options amdgpu noretry=0" # Enable retry, e.g. on page faults - improves stability
    ];
    supportedFilesystems = [ "ntfs" ];
    initrd.systemd.enable = true; # Mostly for boot logging
    loader = fop-utils.mkDefaultRecursively {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 16;
      };
      efi.canTouchEfiVariables = true;
    };
    tmp = {
      useTmpfs = false; # NOTE: tmpfs is static, so packages that would take up more space for building can fail unless it's set extremely high to accomodate
      cleanOnBoot = true;
    };
  };

  fileSystems = {
    # NOTE: Make sure the other boot partition is not labeled with NIXBOOT, otherwise funny generation rollback happens
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXMAIN";
      fsType = "ext4";
    };
  };
}
