{ config, lib, pkgs, ... }:
with lib; {
  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.packages = with pkgs; [
    neofetch
    update-nix-fetchgit

  ];

  programs = rec {
    # Git
    git = { enable = true; };

    # Shells
    oh-my-posh = {
      enable = true;
      package = pkgs.oh-my-posh;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext
        (builtins.readFile (builtins.fetchurl {
          # TODO: Allow updates without requirement of a specific hash
          url = "https://faupi.net/faupi.omp.json";
          sha256 = "11ay1mvl1hflhx0qiqmz1qn38lwkmr1k4jidsq994ra91fnncsji";
        })));
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    bash = {
      enable = true;
      bashrcExtra = "${oh-my-posh.package}/bin/oh-my-posh disable notice";
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      enableAutosuggestions = true;
      initExtra = "${oh-my-posh.package}/bin/oh-my-posh disable notice";
    };
    command-not-found.enable = true; # Allow shells to show Nix package hints

  };
}
