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
          user = "gamestream";
          # command = "${lib.getExe pkgs.cage} -- ${lib.getExe pkgs.gamescope} -W 1920 -H 1080 -f -e --expose-wayland --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -tenfoot";
          command = lib.getExe (pkgs.writeShellApplication {
            name = "gamestream-session";
            runtimeInputs = with pkgs; [
              cage
              gamescope
              steam
            ];
            text = /*sh*/''
              export WLR_RENDERER=vulkan
              export SDL_VIDEODRIVER=wayland

              exec cage -- gamescope -W 2560 -H 1440 -r 144 -f --hdr-enabled --hdr-itm-enabled -- steam -gamepadui -pipewire-dmabuf
            '';
          });
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
