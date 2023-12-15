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
    publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYR+doU3pidirkz6fD8D1dUAMLyfTZor5lWemGV0WnGF+GqTpS3pbWxWLqaE8nfSAklpc4H+T3pYFmlAbu+jnH1fPdr4rVw9jvaWDu3tTrEpSQjTDqGw9xGfGEgI0mTmrGu3vNGJ6wROdcIBLe+kGmw1TbFIiw3aiQIpHnAc0s90HJ3/zi3XrTBAcmFhCGrQBvjzWSigE0efYiKt0SGKm2B1FfbGUyJ6LX2lX+wOT72A72boZGmd4dsL7Ofbzi2Nk8YTmymW4fGIIBu4DsHJVGE+KlH3wmzCtMeLSGufdk4UsCZEY8jNCYD0JX3kxCgbHdMG/xZgF2OBetRJKOGTFn3yQnX2iZiRKqg+A5z6FdiSgutxQhPLyetiqKeXTGWPZS5ckT3HMldXp2qMG1uMeivmYF6RB+SS5gVWLQiizd/KgRqkX01G7IST2RxBFFVFozBO4hnoPw0zwyVjXpnKJv2lnj7pk6AbgNkaWs4i2lD+b4mhRBAePhShxCC1g0Q8jN1xiNUeJvniH+aXsBuJqG/itv8Pp+JpHJeLwllTTRiPrsM4IP6bQksvJLqtMs4sD9zkU/PpzxrWn/nlD0jT5DKKdHPJlwBpMfhdlV4FD+SYe8Am43ssrJJnAC2sZcjO/Eht96Po5VV0THLapmy6bYPtN1HtOOb2qM/7fNbA3vXQ==";
  };

  # Use our identity file to remotely build | TODO: Figure out a smart way to store private key reproducibly
  programs.ssh.extraConfig = ''
    Host homeserver.local
        IdentitiesOnly yes
        IdentityFile /root/.ssh/nixremote
        User nixremote
  '';
}
