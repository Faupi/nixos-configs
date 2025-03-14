{ pkgs, fop-utils, ... }:
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

  nixpkgs.overlays = [
    (self: super: {
      # TODO: Strip down Nvidia and Intel drivers potentially - https://github.com/NixOS/nixpkgs/blob/95600680c021743fd87b3e2fe13be7c290e1cac4/pkgs/development/libraries/mesa/default.nix#L46-L88
      mesa = fop-utils.makeOptLocal super.mesa "-O2";
      # galliumDrivers = ["llvmpipe" "zink" "radeonsi"]
      # vulkanDrivers = ["swrast" "amd"]

      /*
      pkgs.linuxPackages_zen  # TODO: Also add `boot.kernelParams = [ "amd_pstate=active" ];`
      
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.clr.icd
      */
    })
  ];
}
