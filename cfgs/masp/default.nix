{ config, homeUsers, ... }:
{
  imports = [
    ./hardware.nix # TODO: Fill from generated
    ./audio.nix
  ];

  networking.networkmanager.enable = true;

  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; }) ];
    };
  };

  programs._1password-gui = {
    enable = true;
    # TODO: Switch to fully system-managed solution
    package = config.home-manager.users.masp.programs._1password.package;
  };

  system.stateVersion = "23.11";
}
