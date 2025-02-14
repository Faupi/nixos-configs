{ config, lib, pkgs, ... }:
with lib;
{
  nix = {
    distributedBuilds = mkDefault true;
    buildMachines = lists.optional (config.networking.hostName != "homeserver") {
      hostName = "homeserver.local";
      systems = [
        "x86_64-linux"
        "i686-linux"
      ];
      sshUser = "nixremote";
      protocol = "ssh-ng";
      maxJobs = 6; # TODO: Upgrade RAM :D
      speedFactor = 50;
      supportedFeatures = [
        "big-parallel"
      ];
    };

    # Have builders try to fetch packages themselves
    # TODO: Might be causing self-calling loopback issues in some cases
    # extraOptions = ''
    #   builders-use-substitutes = true
    # '';

    # For homeserver binary cache
    settings = {
      substituters = lists.optional (config.networking.hostName != "homeserver") "http://homeserver.local:5200";
      trusted-public-keys = [
        "homeserver.local:G10mIqv1fWlsZUJehZMBtoZFWLRa+tdkce4CU6i7vdc="
      ];
    };
  };

  # Add builder as known host so we don't have to manually authenticate
  services.openssh.knownHosts."homeserver.local".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtPz4sFgVB4VsHsLHn0ib5hKgeBOXdOwryLMcdjN4ds";

  # Use our identity file to remotely build
  programs.ssh.extraConfig = ''
    Host homeserver.local
      IdentitiesOnly yes
      IdentityFile /root/.ssh/nixremote
      User nixremote
  '';

  # Automatically generate a NixRemote key, print it out on creation to be added under autorized keys on builders
  system.activationScripts.generateNixremoteKey = readFile (pkgs.substituteAll {
    src = ./nixremote-key.sh;
    sshKeygen = getExe' pkgs.openssh "ssh-keygen";
  });
}
