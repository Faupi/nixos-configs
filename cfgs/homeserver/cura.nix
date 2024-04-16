{ config, pkgs, homeUsers, ... }:
{
  # User
  sops.secrets.pw-cura = {
    neededForUsers = true;
    sopsFile = ./secrets.yaml;
  };
  users.users.cura = {
    isNormalUser = true;
    createHome = true;
    description = "Cura forwarder";
    hashedPasswordFile = config.sops.secrets.pw-cura.path;
  };
  home-manager.users.cura = {
    imports = [ (homeUsers.cura { graphical = true; }) ]; # User configs for Cura
  };

  # Remoting
  services.openssh.settings.X11Forwarding = true;
  environment.systemPackages = [ pkgs.waypipe ];
  my = {
    cura.enable = true; # Remoted via X11 forwarding
  };
}
