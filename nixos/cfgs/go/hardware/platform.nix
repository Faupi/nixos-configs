{ pkgs, ... }:
{
  nix.settings.system-features = [
    "gccarch-znver4"
    "benchmark"
    "big-parallel"
    "kvm"
    "nixos-test"
  ];
  nixpkgs.hostPlatform = "x86_64-linux";

  # NOTE: linux_zen 6.14.4 has sensor crash issues, trying xanmod for now
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  hardware.cpu.amd.updateMicrocode = true;
}
