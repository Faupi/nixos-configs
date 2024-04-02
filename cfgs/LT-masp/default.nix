{ pkgs, homeUsers, ... }:
{
  imports = [
    ./hardware.nix
    ./audio.nix
    ./management.nix
  ];

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  my.plasma = { enable = true; };
  services.xserver.displayManager = {
    defaultSession = "plasmawayland";
    sddm.enable = true;
  };

  users.users.masp = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "nm-openvpn" ];
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
