{ config, pkgs, lib, ... }:
{
  # List of quirks:
  # - 0x1b1c:0x0a6b - Corsair HS80 
  #   - Preventing USB reset problem halting Steam Deck docking station USB initialization 
  #   - Disabling volume control since it desyncs with Pipewire and generally is a nuisance with desktop remoting

  # USB
  # https://docs.kernel.org/admin-guide/kernel-parameters.html#selector(exact=usbcore.quirks,type=TextQuoteSelector)
  boot.extraModprobeConfig = /* modconf */ ''  
    options usbcore quirks=0x1b1c:0x0a6b:eg
  '';

  # libinput
  environment.etc = {
    "libinput/local-overrides.quirks".text = ''
      [Corsair HS80]
      MatchUdevType=keyboard
      MatchBus=usb
      MatchVendor=0x1B1C
      MatchProduct=0x0A6B
      AttrEventCode=-KEY_VOLUMEDOWN;-KEY_VOLUMEUP;
    '';
  };
}
