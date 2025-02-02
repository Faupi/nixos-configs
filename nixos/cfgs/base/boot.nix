{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelParams = [ "boot.shell_on_fail" ]; # Enable shell on boot failure
    supportedFilesystems = [ "ntfs" ];
    initrd.systemd.enable = true; # Mostly for boot logging
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 16;
      };
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true; # Mount tmp on tmpfs
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXMAIN";
    fsType = "ext4";
  };
}
