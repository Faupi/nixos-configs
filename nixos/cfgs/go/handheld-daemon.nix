{ lib, ... }: {
  users.users.hhd = {
    group = "hhd";
    home = "/var/lib/handheld-daemon";
    createHome = true;
    isSystemUser = true;
  };
  users.groups.hhd = { };

  services = {
    power-profiles-daemon.enable = lib.mkForce false; # Use PPD emulation in HHD

    handheld-daemon = {
      enable = true;
      user = "hhd";
      ui.enable = true;
      adjustor = {
        enable = true;
        acpiCall.enable = true;
      };
    };
  };
}
