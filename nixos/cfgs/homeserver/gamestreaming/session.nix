{ pkgs, ... }: {
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

    gamemode.enable = true;
  };

  services = {
    # Enable input
    libinput.enable = true;
    inputplumber.enable = true;

    displayManager = {
      enable = true;
      sddm = {
        enable = true;
        wayland.enable = true;
        autoLogin.relogin = true;
      };
      defaultSession = "steam";
      autoLogin = {
        enable = true;
        user = "gamestream";
      };
    };
  };
}
