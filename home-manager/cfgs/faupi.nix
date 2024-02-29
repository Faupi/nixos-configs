{ pkgs, ... }: {
  home.packages = with pkgs; [
    SOCIALS.telegram-desktop
    filelight
    qpwgraph
    cad-blender
  ];

  programs = {
    _1password = {
      enable = true;
      package = pkgs._1password-gui;
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
      # NOTE: Needs open firewall TCP+UDP 1714-1764
      enable = true;
      indicator = true;
    };
  };
}
