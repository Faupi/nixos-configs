{ config, pkgs, lib, ... }:
{
  # Set up 1Password GUI with CLI integration
  # NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"
  #       - plus SSH agent
  # TODO: Add full configuration for this shiz

  security.polkit.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "faupi" ];  # TODO: Create config
  };

  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';
}
