{ ... }: {
  boot.kernelParams = [
    "mem_sleep_default=s2idle" # GOOD
    # "amd_pmc.disable=1"
    # "iommu=soft"
    "pcie_aspm=off" # DUNNO: Disables PCIe link power saving (ASPM)
    "amdgpu.dcdebugmask=0x10" # SEEMED TO FIX IT: Disable Panel Self Refresh (PSR)
    "ec_no_wakeup=1" # Shouldn't do anything really, but good to have
    "amdgpu.dc=1" # Forces full display core path (apparently for s2idle correctness)
  ];

  # Disable "wake on USB" - generally fine to keep to avoid random wake-ups
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{power/wakeup}="disabled"
  '';
}
