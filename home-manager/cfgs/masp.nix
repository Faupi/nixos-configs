{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    (config.lib.nixgl.wrapPackage teams-for-linux)
  ];

  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    _1password = {
      enable = true;
      package = pkgs._1password-gui;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    firefox.profiles.masp.isDefault = true;
  };
}
