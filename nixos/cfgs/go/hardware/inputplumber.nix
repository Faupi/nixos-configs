{ pkgs, lib, ... }:
let
  # TODO: Open upstream PR?
  package = pkgs.unstable.inputplumber.overrideAttrs (old: {
    # Patch absolute path calls
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/udev/mod.rs \
        --replace-fail '"/bin/chmod"' '"${lib.getExe' pkgs.coreutils "chmod"}"'

      substituteInPlace rootfs/usr/lib/systemd/system/inputplumber.service \
        --replace-fail '/usr/bin/inputplumber' "$out/bin/inputplumber"
    '';

    # https://github.com/NixOS/nixpkgs/pull/463014
    postInstall = (old.postInstall or "") + ''
      # remove testing dbus service
      rm $out/share/dbus-1/system-services/org.shadowblip.InputPlumber.service
    '';
  });
in
{
  boot = {
    initrd.availableKernelModules = [
      "uinput"
      "uhid"
    ];
    kernelModules = [
      "uinput"
      "uhid"
    ];
  };

  services = {
    inputplumber = {
      enable = true;
      package = package;
    };
    dbus.packages = [ package ]; # Required for something: https://github.com/NixOS/nixpkgs/pull/463014
  };
}
