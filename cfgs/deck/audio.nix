{ config, pkgs, lib, ... }:
{
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  my.easyeffects = {
    enable = true;
    user = "faupi";
  };
}