{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
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
    oh-my-posh = {
      enable = true;
      package = with pkgs;
        oh-my-posh;
      settings = with builtins; fromJSON (unsafeDiscardStringContext (readFile ./oh-my-posh.json));
      enableZshIntegration = true;
    };

    # Fuzzy finder 
    fzf = {
      enable = true;
      package = with pkgs;
        fzf;
      enableZshIntegration = true;
    };

    # Smarter cd
    zoxide = {
      enable = true;
      package = with pkgs;
        zoxide;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    # History search
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      package = with pkgs;
        zsh;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        export PATH=${config.home.homeDirectory}/.local/bin:$PATH

        ${lib.getExe config.programs.oh-my-posh.package} disable notice
        ${lib.getExe (with pkgs; any-nix-shell)} zsh | source /dev/stdin
        source ${./shell-lib/functions.sh}
        source ${./shell-lib/zsh-keybinds.zsh}
        source ${./shell-lib/zsh-nvm.zsh}
      '';

      sessionVariables = {
        FZF_DEFAULT_OPTS = "--height=20% --info=inline-right --reverse --header-first";
      };
    };
  };
}
