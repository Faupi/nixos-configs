{ lib, pkgs, ... }:
{
  imports = [
    ./shell
  ];

  services.home-manager = {
    autoExpire = {
      enable = true;
      # Defaults, but might as well have em
      frequency = "monthly";
      timestamp = "-30 days";
    };
  };

  nix = {
    # TODO: Automatically set to matching version with system
    package = lib.mkDefault (pkgs.lix);
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      http-connections = 100; # Binary cache connections limit
    };
  };

  home.packages = with pkgs; [
    home-manager

    neofetch
    update-nix-fetchgit
    nurl
    tree
    inotify-tools
    tldr
    btop
    devenv
  ];

  programs = {
    git = {
      enable = true;
      extraConfig = {
        pull.rebase = false;
        core.autocrlf = false; # Fucks with cross-platform usage, seen as a bad default
      };
    };
  };
}
