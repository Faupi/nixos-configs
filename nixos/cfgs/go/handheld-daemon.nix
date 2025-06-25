{ lib, ... }: {
  # users.users.hhd = {
  #   group = "hhd";
  #   home = "/var/lib/handheld-daemon";
  #   createHome = true;
  #   isSystemUser = true;
  # };
  # users.groups.hhd = { };

  services = {
    power-profiles-daemon.enable = true; # REVIEW: Seems to get disabled by handheld-daemon fine
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
