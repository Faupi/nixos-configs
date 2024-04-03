# TODO: Register build server as a substitute / nix store server

{ config, lib, pkgs, ... }:
with lib;
{
  nix = {
    distributedBuilds = true;
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
    extraOptions = ''
      builders-use-substitutes = true
    '';

    # Substitution caches for already build packages
    settings = {
      # Set as highest priority
      substituters = [
        "ssh-ng://nixremote@homeserver.local"
      ];
      trusted-public-keys = [
        "homeserver:uDaW5ok2YxkmtnzBQpA4jlK8C5VtROozojqLtMsEfTQ="
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

  # Automatically generate a NixRemote key, print it out on creation to be added under authorized keys on builders
  system.activationScripts.generateNixremoteKey = readFile (pkgs.substituteAll {
    src = ./nixremote-key.sh;
    sshKeygen = getExe' pkgs.openssh "ssh-keygen";
  });
}
