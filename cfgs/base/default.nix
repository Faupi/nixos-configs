{ config, pkgs, lib, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  environment.shellAliases = {
    nixconf = "nano /etc/nixos/configuration.nix";
    nixreload = "nix flake update github:Faupi/home-nix; nixos-rebuild switch --flake github:Faupi/home-nix; exec bash";
  };
}