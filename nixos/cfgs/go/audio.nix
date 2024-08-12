{ lib, ... }:
with lib;
{
  hardware.pulseaudio.enable = mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    lowLatency = {
      enable = true;
      quantum = 256;
      rate = 48000;
    };
  };
}
