{ pkgs, ... }: {
  flake-configs = {
    audio = {
      enable = true;
      user = "gamestream";
    };
  };

  programs.steam = {
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

  services.displayManager = {
    enable = true;
    sddm = {
      enable = true;
      autoLogin.relogin = true;
    };
    defaultSession = "gamescope-wayland";
    autoLogin = {
      enable = true;
      user = "gamestream";
    };
  };
}
