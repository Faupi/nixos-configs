{ ... }: {
  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = true;
    };

    _1password = {
      enable = true;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    git = {
      userName = "Faupi";
      userEmail = "matej.sp583@gmail.com";
    };

    firefox.profiles.faupi.isDefault = true;
  };

  services = {
    kdeconnect = {
      # TODO: Open firewall TCP+UDP 1714-1764
      enable = true;
      indicator = true;
    };
  };
}
