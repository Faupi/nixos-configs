{ config, lib, pkgs, ... }:
with lib; {
  programs.home-manager.enable = true;

  nix = {
    package = mkDefault pkgs.nix;
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
      package = pkgs.oh-my-posh;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext
        (builtins.readFile (builtins.fetchurl {
          # TODO: Allow updates without requirement of a specific hash - create a resource flake
          url = "https://faupi.net/faupi.omp.json";
          sha256 = "11ay1mvl1hflhx0qiqmz1qn38lwkmr1k4jidsq994ra91fnncsji";
        })));
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    # TODO: Switch to any-nix-shell and remove bash definitions?
    bash = {
      enable = true;
      bashrcExtra = ''
        ${config.programs.oh-my-posh.package}/bin/oh-my-posh disable notice
        source ${./shell-lib/functions.sh}
      '';
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      enableAutosuggestions = true;
      initExtra = ''
        ${config.programs.oh-my-posh.package}/bin/oh-my-posh disable notice
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
        source ${./shell-lib/functions.sh}
        source ${./shell-lib/zsh-keybinds.zsh}
      '';
    };
    command-not-found.enable = true; # Allow shells to show Nix package hints

  };
}
