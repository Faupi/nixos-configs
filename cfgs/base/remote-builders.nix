{ configs, pkgs, lib, ...}:
{
  nix.buildMachines = [ 
    {
      hostName = "home.local";
      systems = [
        "x86_64-linux"
        "i686-linux"
      ];
      sshUser = "nixremote";
      protocol = "ssh-ng";
      maxJobs = 6;
      speedFactor = 50;
      supportedFeatures = [
        "big-parallel"
      ];
	  }
  ];
}
