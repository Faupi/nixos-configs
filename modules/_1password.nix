{ config, pkgs, lib, ... }:
{
  security.polkit.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "faupi" ];  # TODO: Create config
  };
}