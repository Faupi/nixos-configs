{ config, lib, pkgs, ... }: {
  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    # TODO: Check if switching to non-FHS everywhere would be better overall
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
