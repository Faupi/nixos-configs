{ ... }: {
  nix.settings.system-features = [
    "benchmark"
    "big-parallel"
    "gccarch-znver4"
    "kvm"
    "nixos-test"
  ];
  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
    gcc.arch = "znver4";
    gcc.tune = "znver4";
  };

  hardware.cpu.amd.updateMicrocode = true;

  /* 
    TODO: Create wrapper for un-optimizing packages, so they build and function - see https://github.com/caffineehacker/nix/blob/main/machines/framework/configuration.nix
    
    Failing:
    - clang
    - rustc
  */
}
