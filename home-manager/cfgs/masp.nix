{ ... }: {
  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = false;
    };

    _1password = {
      enable = true;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    firefox.profiles.masp.isDefault = true;
  };
}
