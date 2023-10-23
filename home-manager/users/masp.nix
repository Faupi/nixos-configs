{ config, lib, pkgs, ... }: {
  programs = {
    # TODO: Check if switching to non-FHS would be better overall
    vscode.package = pkgs.vscodium;

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
