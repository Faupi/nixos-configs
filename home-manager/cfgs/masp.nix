{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      (config.lib.nixgl.wrapPackage krita)

      (config.lib.nixgl.wrapPackage epiphany)

      corepack

      (config.lib.nixgl.wrapPackage moonlight-qt)

      # TODO: Create graphical base config?
      (config.lib.nixgl.wrapPackage filelight)
      qpwgraph
    ];
  };

  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    # 1Password is taken from system package manager

    firefox.profiles.masp.isDefault = true;
  };
}
