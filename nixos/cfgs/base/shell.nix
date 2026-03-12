{ config, pkgs, ... }: {
  users.defaultUserShell = with pkgs;
    zsh;
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
}
