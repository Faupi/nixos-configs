{ lib, pkgs, ... }:
let
  # TODO: Remove wrapper when updating from 25.11 NixOS / to 4+ HHD
  adjustorPyPath = pkgs.python3Packages.makePythonPath [ pkgs.adjustor ];
in
{
  services = {
    power-profiles-daemon.enable = false; # Still can't decide whether to use PPD or HHD c:
    inputplumber.enable = lib.mkForce false; # REVIEW: steamos-manager might need it for something: https://github.com/Jovian-Experiments/Jovian-NixOS/commit/02a238236e3a859c43c7f940f2e86b281341a436

    handheld-daemon = {
      enable = true;
      user = "faupi"; # NOTE: Should be main user!
      ui.enable = true;
      adjustor = {
        enable = true;
        loadAcpiCallModule = true;
      };
    };
  };

  systemd.services.handheld-daemon.environment = {
    PYTHONPATH = adjustorPyPath;
    PYTHONNOUSERSITE = "1"; # Don't pull user packages
  };
}
