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

  programs = {
    # Git
    git = { enable = true; };

    # Shells
    oh-my-posh = {
      enable = true;
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
      bashrcExtra = "${pkgs.oh-my-posh}/bin/oh-my-posh disable notice";
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      enableAutosuggestions = true;
      initExtra = "${pkgs.oh-my-posh}/bin/oh-my-posh disable notice";
    };
    command-not-found.enable = true; # Allow shells to show Nix package hints
    
  };
}
