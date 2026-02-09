{ ... }: {
  imports = [
    ./hibernate.nix
    ./power-profiles.nix
  ];

  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "amdgpu.dcdebugmask=0x10" # Disable Panel Self Refresh (PSR) - seems to have resolved issues with GPU wake-up
    "amdgpu.dc=1" # Forces full display core path (apparently for s2idle correctness)
  ];

  services.udev.extraRules = ''
    # Disable "wake on USB" for HID - generally fine to keep to avoid random wake-ups
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

    # Disable wake-up on charger connect/disconnect/whatever
    SUBSYSTEM=="platform", KERNEL=="USBC*", ATTR{power/wakeup}="disabled"
  '';
}
