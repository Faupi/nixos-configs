{ config, lib, pkgs, ... }:
with lib; {
  imports = [
    # TODO: Probably not the best way to do it as it's a config but too bad
    ./command-not-found
  ];

  programs.home-manager.enable = true;

  nix = {
    package = mkDefault pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.packages = with pkgs; [
    neofetch
    update-nix-fetchgit
    nurl
    tree
    inotify-tools
    tldr

  ];

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

    # Shells
    oh-my-posh = {
      enable = true;
      package = pkgs.oh-my-posh;
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext
        (builtins.readFile (builtins.fetchurl {
          # TODO: Allow updates without requirement of a specific hash - create a resource flake
          url = "https://faupi.net/faupi.omp.json";
          sha256 = "1806hgcjy0yjk546mm1ph275i1n9fwkw04xrxfapswrfss45yai2";
        })));
      enableZshIntegration = true;
    };
    # Fuzzy finder 
    fzf = {
      enable = true;
      package = pkgs.fzf;
      enableZshIntegration = true;
    };
    # Smarter cd
    zoxide = {
      enable = true;
      package = pkgs.zoxide;
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

      sessionVariables = {
        FZF_DEFAULT_OPTS = "--height=20% --info=inline-right --reverse --header-first";
      };
    };
  };
}
