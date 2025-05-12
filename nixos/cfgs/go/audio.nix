{ lib, ... }:
{
  services.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Add user to the audio group so rtkit stuff applies
  # TODO: Change to main user when that's set up
  users.users.faupi.extraGroups = [ "pipewire" ];
}
