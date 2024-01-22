{ pkgs, ... }: {
  home.packages = with pkgs;
    let
      vesktop = SOCIALS.vesktop.overrideAttrs (oldAttrs: {
        desktopItems = [
          (
            lib.lists.last oldAttrs.desktopItems  # This is dumb but too bad
            // {
              # I don't like the Vencord icon - override it
              # + overriding the desktop file would need actual Discord installed
              icon = "discord";
            }
          )
        ];
      });
    in
    [
      vesktop
    ];

  programs = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      virtualKeyboard.enable = true;
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
