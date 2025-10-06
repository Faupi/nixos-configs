{ config, lib, pkgs, ... }: {
  services = {
    power-profiles-daemon.enable = false; # Still can't decide whether to use PPD or HHD c:
    inputplumber.enable = lib.mkForce false; # REVIEW: steamos-manager might need it for something: https://github.com/Jovian-Experiments/Jovian-NixOS/commit/02a238236e3a859c43c7f940f2e86b281341a436

    handheld-daemon = {
      enable = true;
      user = "faupi"; # NOTE: Should be main user!
      package = pkgs.handheld-daemon.override { useAdjustor = true; };
      ui = {
        enable = true;
        package = pkgs.unstable.handheld-daemon-ui;
      };
    };
  };

  # To make Adjustor TDP work
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
    kernelModules = [ "acpi_call" ];
  };
}
