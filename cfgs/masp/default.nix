{ homeUsers, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./management.nix
  ];

  networking.networkmanager.enable = true;

  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  my.plasma = { enable = true; };
  services.xserver.displayManager.defaultSession = "plasmawayland";

  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
  home-manager.users = {
    masp = {
      imports = [ (homeUsers.masp { graphical = true; }) ];
    };
  };

  # TODO: Move to a general module?
  programs = {
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "masp" ];
    };
    _1password.enable = true;
  };

  system.stateVersion = "23.11";
}
