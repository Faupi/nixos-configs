{ ... }: {
  boot.kernelParams = [
    "mem_sleep_default=s2idle" # GOOD
    "amdgpu.dcdebugmask=0x10" # SEEMED TO FIX IT: Disable Panel Self Refresh (PSR)
    "amdgpu.dc=1" # Forces full display core path (apparently for s2idle correctness)
  ];

  # Disable "wake on USB" for HID - generally fine to keep to avoid random wake-ups
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{bInterfaceClass}=="03", ATTR{power/wakeup}="disabled"
  '';
}
