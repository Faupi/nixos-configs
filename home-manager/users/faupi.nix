{ lib, pkgs, fop-utils, ... }@args: {
  programs = {
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
  };

  services = {
    kdeconnect = {
      # TODO: Open firewall TCP+UDP 1714-1764
      enable = true;
      indicator = true;
    };
  };
}
