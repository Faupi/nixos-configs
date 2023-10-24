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
          # TODO: Allow updates without requirement of a specific hash
          url = "https://faupi.net/faupi.omp.json";
          sha256 = "0d3m52sbi2q510g39iqpffgv0yic38inbp6qdfy66sk4czc8nk6w";
        })));
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    # TODO: Switch to any-nix-shell and remove bash definitions?
    bash = {
      enable = true;
      bashrcExtra = ''
        ${config.programs.oh-my-posh.package}/bin/oh-my-posh disable notice
        source ${./shell/functions.sh}
      '';
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      enableAutosuggestions = true;
      initExtra = ''
        ${config.programs.oh-my-posh.package}/bin/oh-my-posh disable notice
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
        source ${./shell/functions.sh}
        source ${./shell/zsh-keybinds.zsh}
      '';
    };
    command-not-found.enable = true; # Allow shells to show Nix package hints

  };
}
