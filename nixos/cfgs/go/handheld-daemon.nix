{ lib, ... }: {
  services = {
    power-profiles-daemon.enable = lib.mkForce false;
    inputplumber.enable = lib.mkForce false; # REVIEW: steamos-manager might need it for something: https://github.com/Jovian-Experiments/Jovian-NixOS/commit/02a238236e3a859c43c7f940f2e86b281341a436

    handheld-daemon = {
      enable = true;
      user = "faupi"; # NOTE: Should be main user!
      ui.enable = true;
      adjustor = {
        enable = true;
        acpiCall.enable = true;
      };
    };
  };
}
