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
    tree
    inotify-tools

  ];

  # Enables 192kHz rates on Pipewire, move this if it becomes a problem
  xdg.configFile."PipeWire 192kHz support" = {
    target = "pipewire/pipewire.conf.d/60-faupi-hm.conf";
    text = ''
      context.properties = {
        default.clock.rate          = 192000
        default.clock.allowed-rates = [ 44100 48000 88200 96000 192000 ]
      }
    '';
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
          sha256 = "1806hgcjy0yjk546mm1ph275i1n9fwkw04xrxfapswrfss45yai2";
        })));
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    # TODO: Switch to any-nix-shell and remove bash definitions?
    bash = {
      enable = true;
      bashrcExtra = ''
        export PATH=${config.home.homeDirectory}/.local/bin:$PATH

        ${getExe' config.programs.oh-my-posh.package "oh-my-posh"} disable notice
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
