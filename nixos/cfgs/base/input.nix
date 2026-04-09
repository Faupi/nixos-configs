{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # X11 keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
    options = mkForce ""; # Mostly to disable terminate
  };

  # Apply a default mouse profile
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.9";
    };
  };
}
