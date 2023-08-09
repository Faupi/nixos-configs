{ config, pkgs, lib, ... }:
{
  # Set up 1Password GUI with CLI integration
  # NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"

  security.polkit.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "faupi" ];  # TODO: Create config
  };
}