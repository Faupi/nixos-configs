{ ... }:
{
  imports = [
    ./graphics.nix
    # ./optimized-overlays.nix  # NOTE: Needs intensive testing, optimizations don't seem to benefit performance, Steam randomly crashes with them.
    ./platform.nix
    ./sensors.nix
  ];

  powerManagement.enable = true; # Battery and general power management

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ];
  };

  # Thunderbolt management service, not sure if it does much but good to have
  services.hardware.bolt.enable = true;

  # SSD trimming
  services.fstrim.enable = true;

  services.udev = {
    # Fix accelerometer rotation (default is left side up)
    extraHwdb = ''
      sensor:modalias:platform:HID-SENSOR-200073*:dmi:*svnLENOVO*:pn83E1:*
        ACCEL_MOUNT_MATRIX=0, 1, 0; -1, 0, 0; 0, 0, 1
    '';

    # Ignore kwin tablet mode if controller is disconnected
    # + ignore touchpads (real + emulated) as mouse inputs - all is handled through Steam Input
    # NOTE: Each state of the controller is taken as a different product ID, it seems
    extraRules = ''
      KERNEL=="event[0-9]*", SUBSYSTEM=="usb", \
        ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="6184", \
        TAG+="kwin-ignore-tablet-mode"

      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", \
        ENV{ID_VENDOR_ID}=="17ef", ENV{ID_MODEL_ID}=="6182", \
        ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", \
        ATTRS{id/vendor}=="054c", ATTRS{id/product}=="0df2", \
        ENV{ID_INPUT_TOUCHPAD}=="1", \
        ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';
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
