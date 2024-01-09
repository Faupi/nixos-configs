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
    nurl

  ];

  # Set up KRunner autostart so there's no waiting for the initial request
  home.file."KRunner autostart" = config.lib.fop-utils.makeAutostartItem {
    name = "krunner-autostart";
    desktopName = "KRunner autostart";
    exec = "krunner -d";
    noDisplay = true;
    extraConfig = {
      OnlyShowIn = "KDE";
    };
  };

  programs = {
    # Git
    git = {
      enable = true;
      extraConfig = { pull.rebase = false; };
    };

    # Shells
    oh-my-posh = {
      enable = true;
      package = pkgs.oh-my-posh;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext
        (builtins.readFile (builtins.fetchurl {
          # TODO: Allow updates without requirement of a specific hash - create a resource flake
          url = "https://faupi.net/faupi.omp.json";
          sha256 = "0fdn2ddwxh0lws3v0s4fispxf9c29sayc4zxbirrifnpjsh71ayj";
        })));
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    # TODO: Switch to any-nix-shell and remove bash definitions?
    bash = {
      enable = true;
      bashrcExtra = ''
        export PATH=${config.home.homeDirectory}/.local/bin:$PATH

        ${config.programs.oh-my-posh.package}/bin/oh-my-posh disable notice
        source ${./shell-lib/functions.sh}
      '';
    };
    zsh = {
      enable = true;
      package = pkgs.zsh;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        export PATH=${config.home.homeDirectory}/.local/bin:$PATH

        ${getExe' config.programs.oh-my-posh.package "oh-my-posh"} disable notice
        ${getExe' pkgs.any-nix-shell "any-nix-shell"} zsh | source /dev/stdin
        source ${./shell-lib/functions.sh}
        source ${./shell-lib/zsh-keybinds.zsh}
        source ${./shell-lib/zsh-nvm.zsh}
      '';
    };
    command-not-found.enable = true; # Allow shells to show Nix package hints
  };
}
