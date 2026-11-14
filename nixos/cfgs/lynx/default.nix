{ config, pkgs, homeUsers, system, lib, fop-utils, inputs, ... }@args:
let
  cfg = {
    mainInterface = "enp6s0";
    defaultDisplay = "DP-1";
    sunshineAudioSource = "sunshine.source";
  };

  inherit (lib) getExe;
  inherit (fop-utils) mkForceRecursively;
in
{
  imports = (map (mod: (import mod (args // { inherit cfg; }))) [
    ./boot.nix
    ./graphics.nix
    ./hardware.nix
    ./keyd.nix
    ./playit.nix
    ./sunshine.nix
    ./swap.nix
    ./wake-on-lan.nix
  ]);

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  users.users.faupi.extraGroups = [ "gamemode" "input" "video" "audio" ];
  home-manager.users = {
    faupi = {
      imports = [ (homeUsers.faupi { inherit system; }) ];

      programs.dank-material-shell = {
        settings = mkForceRecursively {
          customPowerActionLogout = "";
          lockAtStartup = false;
        };
      };
    };
  };

  programs = {
    kdeconnect.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    steam = {
      enable = true;
      extest.enable = false;

      # Match Millennium to Steam libraries to avoid symbol mismatch crashes
      package = inputs.millennium.packages.${system}.millennium-steam.override {
        millennium = inputs.millennium.packages.${system}.millennium.override (old: {
          stdenv = pkgs.gcc15Stdenv;
          pkgsi686Linux = old.pkgsi686Linux // {
            stdenv = pkgs.pkgsi686Linux.gcc15Stdenv;
          };
        });
      };

      extraPackages = with pkgs; [
        steamtinkerlaunch
        gamescope
      ];
      protontricks.enable = true;

      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  services = {
    flatpak.enable = true;
    openssh.enable = true;
    udisks2.enable = true; # For Dolphin drive view #TODO: Enable globally?
    fwupd.enable = true;
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
    };
  };

  systemd.services.ollama.environment = {
    OLLAMA_FLASH_ATTENTION = "1";
    OLLAMA_KV_CACHE_TYPE = "q8_0";
  };

  environment.systemPackages = with pkgs; [
    r2modman

    (makeAutostartItem rec {
      name = "steam";
      package = makeDesktopItem {
        inherit name;
        desktopName = "Steam";
        exec = "${getExe config.programs.steam.package} -silent %U";
        icon = "steam";
      };
    })
  ];

  system.stateVersion = "25.11";
}
