{ lib, pkgs, fop-utils, ... }@args: {
  programs = {
    vscode.package = pkgs.vscodium-fhs;

    _1password = {
      enable = true;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };
  };
}
