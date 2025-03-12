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

  boot.kernelPackages = pkgs.linuxPackages_zen;

  hardware.cpu.amd.updateMicrocode = true;
}
