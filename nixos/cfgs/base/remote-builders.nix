{ config, lib, pkgs, ... }:
with lib;
{
  nix = {
    distributedBuilds = mkDefault true;
    buildMachines = lists.optional (config.networking.hostName != "beaver") {
      hostName = "beaver.local";
      systems = [
        "x86_64-linux"
        "i686-linux"
      ];
      sshUser = "nixremote";
      protocol = "ssh-ng";
      maxJobs = 6;
      speedFactor = 2;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    };

    # For beaver binary cache
    settings = {
      substituters = lists.optional (config.networking.hostName != "beaver") "http://beaver.local:5200";
      trusted-public-keys = [
        "beaver.local:G10mIqv1fWlsZUJehZMBtoZFWLRa+tdkce4CU6i7vdc="
      ];
    };
  };

  # Add builder as known host so we don't have to manually authenticate
  services.openssh.knownHosts."beaver.local".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHw8M3uJe8UAy0m2n3rtMfDKS/jlTNC4pvOwrLtEPMVr";

  # Use our identity file to remotely build
  programs.ssh.extraConfig = ''
    Host beaver.local
      IdentitiesOnly yes
      IdentityFile /root/.ssh/nixremote
      User nixremote
  '';

  # Automatically generate a NixRemote key, print it out on creation to be added under autorized keys on builders
  system.activationScripts.generateNixremoteKey = readFile (pkgs.replaceVars ./nixremote-key.sh {
    sshKeygen = getExe' pkgs.openssh "ssh-keygen";
  });
}
