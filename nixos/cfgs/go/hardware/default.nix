{ ... }:
{
  imports = [
    ./graphics.nix
    ./platform.nix
    ./sensors.nix
  ];

  powerManagement.enable = true; # Battery and general power management

  hardware.bluetooth = {
    enable = true;
    disabledPlugins = [ "sap" ];
  };

  services.udev = {
    # Fix accelerometer rotation (default is left side up)
    extraHwdb = ''
      sensor:modalias:platform:HID-SENSOR-200073*:dmi:*svnLENOVO*:pn83E1:*
        ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, 1
    '';

    # Ignore kwin tablet mode if controller is disconnected
    # NOTE: Each state of the controller is taken as a different product ID, it seems
    extraRules = ''
      KERNEL=="event[0-9]*", SUBSYSTEM=="usb", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="6184", TAG+="kwin-ignore-tablet-mode"
    '';
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
