{ ... }:
{
  nix = {
    buildMachines = [
      {
        hostName = "homeserver.local";
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
        sshUser = "nixremote";
        protocol = "ssh-ng";
        maxJobs = 3; # TODO: Upgrade RAM :D
        speedFactor = 50;
        supportedFeatures = [
          "big-parallel"
        ];
      }
    ];

    # Have builders try to fetch packages themselves
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  # Add builder as known host so we don't have to manually authenticate
  services.openssh.knownHosts."homeserver.local" = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtPz4sFgVB4VsHsLHn0ib5hKgeBOXdOwryLMcdjN4ds";
  };

  # Use our identity file to remotely build | TODO: Figure out a smart way to store private key reproducibly
  programs.ssh.extraConfig = ''
    Host homeserver.local
      IdentitiesOnly yes
      IdentityFile /root/.ssh/nixremote
      User nixremote
  '';
}
