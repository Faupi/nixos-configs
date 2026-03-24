{ pkgs, lib, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = "gamestream";
    };
  };

  programs = {
    steam = {
      enable = true;
      extest.enable = false;

      extraCompatPackages = with pkgs; [
        (proton-ge-bin.override { steamDisplayName = "GE-Proton (nix)"; })
      ];
      protontricks.enable = true;

      gamescopeSession = {
        enable = true;
      };

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    gamemode.enable = true;
  };

  services = {
    xserver.enable = false; # Assuming no other Xserver needed
    getty.autologinUser = "gamestream";
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.cage} -- ${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --expose-wayland --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -tenfoot";
          user = "gamestream";
        };
      };
    };

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };

  environment.systemPackages = with pkgs; [
    gamescope-wsi # HDR won't work without this
  ];
}
