{ configs, pkgs, lib, ...}:
{
  nix.buildMachines = [ 
    {
      hostName = "home.local";
      system = "x86_64-linux";
      sshUser = "nixremote";
      protocol = "ssh-ng";
      maxJobs = 6;
      speedFactor = 5;
	  }
  ];
}
