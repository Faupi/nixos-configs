{ config, pkgs, ... }: {
  users.defaultUserShell = pkgs.zsh;
  environment = {
    shells = [ config.users.defaultUserShell ];
    pathsToLink = [
      "/share/zsh" # Auto-completion
    ];
  };
  programs.command-not-found.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
  };

  # Password feedback for sudo
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  # Nano unified
  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';
}
