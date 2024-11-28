{ config, lib, pkgs, ... }:
{
  programs.home-manager.enable = true;

  nix = {
    package = lib.mkDefault (with pkgs; nix);
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      http-connections = 100; # Binary cache connections limit
    };
  };

  home.packages = with pkgs; [
    neofetch
    update-nix-fetchgit
    nurl
    tree
    inotify-tools
    tldr
  ];

  # TODO: Check if this is still needed with the pipewire config handler from nix-gaming
  xdg.configFile."PipeWire custom" = {
    target = "pipewire/pipewire.conf.d/60-faupi-hm.conf";
    text = ''
      context.properties = {
        default.clock.allowed-rates = [ 48000 96000 192000 ]
        default.clock.min-quantum   = 512
      }
    '';
  };

  programs = {
    # Git
    git = {
      enable = true;
      extraConfig = {
        pull.rebase = false;
        core.autocrlf = false; # Fucks with cross-platform usage, seen as a bad default
      };
    };

    #region Shells
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

      initExtra = ''
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
