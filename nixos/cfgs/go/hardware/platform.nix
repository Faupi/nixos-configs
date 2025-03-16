{ pkgs, fop-utils, lib, ... }:
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
    (self: super:
      let
        optimize = package: extraCFlags:
          if package.stdenv.hostPlatform.system == "x86_64-linux"
          then fop-utils.mkLocalOptimizedPackage super package ("-O2" + toString extraCFlags)
          else package;
      in
      {
        # Note - do not override optimization
        # linuxPackages_zen = pkgs.linuxPackagesFor (fop-utils.mkLocalOptimizedPackage super super.linuxPackages_zen.kernel "");

        mesa = ((optimize super.mesa "").override {
          galliumDrivers = [ "llvmpipe" "zink" "radeonsi" ];
          vulkanDrivers = [ "swrast" "amd" ];
        }).overrideAttrs (old: {
          # Force-remove output, as we don't build it and the output definition is not conditional
          # https://github.com/NixOS/nixpkgs/pull/371771
          outputs = lib.remove "spirv2dxil" old.outputs;
        });

        rocmPackages.clr = optimize super.rocmPackages.clr "";

        zen-browser = optimize super.zen-browser "";
      })
  ];
}
