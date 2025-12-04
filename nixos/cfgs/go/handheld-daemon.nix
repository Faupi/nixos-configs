{ lib, pkgs, ... }: {
  services = {
    power-profiles-daemon.enable = false; # Still can't decide whether to use PPD or HHD c:
    inputplumber.enable = lib.mkForce false; # REVIEW: steamos-manager might need it for something: https://github.com/Jovian-Experiments/Jovian-NixOS/commit/02a238236e3a859c43c7f940f2e86b281341a436

    handheld-daemon = {
      enable = true;
      user = "faupi"; # NOTE: Should be main user!
      package = pkgs.unstable.handheld-daemon;
      ui = {
        enable = true;
        package = pkgs.unstable.handheld-daemon-ui;
      };
      adjustor = {
        enable = true;
        package = pkgs.unstable.adjustor;
        loadAcpiCallModule = true;
      };
    };
  };
}
