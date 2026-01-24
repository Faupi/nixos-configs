{ pkgs, lib, ... }: {
  systemd.oomd.enable = false;

  services.earlyoom = {
    enable = true;

    freeMemThreshold = 6;
    freeMemKillThreshold = 4;
    freeSwapThreshold = 15;
    freeSwapKillThreshold = 10;

    reportInterval = 0; # Disable reports

    extraArgs = [
      "--prefer"
      "^(vivaldi-bin|java|node|electron|chromium|chrome|cc1plus|gcc|g\\+\\+|clang|clang\\+\\+|rustc|ld|lld|ld\\.lld|nix-collect-garbage|nix-store|nix-build|nixos-rebuild)$"
      "--avoid"
      "^(systemd|systemd-journald|systemd-logind|dbus-daemon|dbus-broker|NetworkManager|wpa_supplicant|pipewire|wireplumber|rtkit-daemon|udevd|sshd|sddm|gdm|greetd|login|agetty|gamescope|Xwayland|kwin_wayland|plasmashell)$"
    ];

    killHook = lib.getExe (pkgs.writeShellApplication {
      name = "earlyoom-kill-hook";
      runtimeInputs = with pkgs; [ util-linux ];
      text = /*sh*/''
        logger -t earlyoom "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
      '';
    });
  };
}
